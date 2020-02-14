defmodule Kalevala.Foreman do
  @moduledoc """
  Session Foreman

  Manages data flowing from the player into the game.
  """

  use GenServer

  require Logger

  alias Kalevala.Conn
  alias Kalevala.Event

  defstruct [
    :character,
    :character_module,
    :controller,
    :options,
    :presence_module,
    :protocol,
    :quit_view,
    session: %{}
  ]

  @doc """
  Start a new foreman for a connecting player
  """
  def start(protocol_pid, options) do
    options = Keyword.merge(options, protocol: protocol_pid)
    DynamicSupervisor.start_child(__MODULE__.Supervisor, {__MODULE__, options})
  end

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @impl true
  def init(opts) do
    opts = Enum.into(opts, %{})

    state = %__MODULE__{
      protocol: opts[:protocol],
      character_module: opts.character_module,
      controller: opts.initial_controller,
      presence_module: opts.presence_module,
      quit_view: opts.quit_view,
      options: %{}
    }

    {:ok, state, {:continue, :init_controller}}
  end

  @doc false
  def new_conn(state) do
    %Conn{
      character: state.character,
      session: state.session,
      private: %Conn.Private{
        character_module: state.character_module
      }
    }
  end

  @impl true
  def handle_continue(:init_controller, state) do
    new_conn(state)
    |> state.controller.init()
    |> handle_conn(state)
  end

  @impl true
  def handle_info({:recv, :text, data}, state) do
    new_conn(state)
    |> state.controller.recv(data)
    |> handle_conn(state)
  end

  def handle_info({:recv, :option, option}, state) do
    new_conn(state)
    |> state.controller.option(option)
    |> handle_conn(state)
  end

  def handle_info(event = %Event{}, state) do
    new_conn(state)
    |> state.controller.event(event)
    |> handle_conn(state)
  end

  def handle_info(event = %Event.Movement.Voting{}, state) do
    event = Event.set_end_time(event)

    :telemetry.execute([:kalevala, :movement, :voting, event.state], %{
      total_time: Event.timing(event),
      from: event.from,
      to: event.to,
      character: event.character.id,
      reason: event.reason
    })

    new_conn(state)
    |> state.controller.event(event)
    |> handle_conn(state)
  end

  def handle_info({:route, event = %Event{}}, state) do
    new_conn(state)
    |> Map.put(:events, [event])
    |> handle_conn(state)
  end

  def handle_info(event = %Event.Display{}, state) do
    new_conn(state)
    |> state.controller.display(event)
    |> handle_conn(state)
  end

  def handle_info(:terminate, state) do
    notify_disconnect(state)
    DynamicSupervisor.terminate_child(__MODULE__.Supervisor, self())
    {:noreply, state}
  end

  defp notify_disconnect(%{character: nil}), do: :ok

  defp notify_disconnect(state) do
    {quit_view, quit_template} = state.quit_view

    event = %Event.Movement{
      character: state.character,
      direction: :from,
      reason: quit_view.render(quit_template, %{character: state.character}),
      room_id: state.character.room_id
    }

    new_conn(state)
    |> Map.put(:events, [event])
    |> send_events()
  end

  @doc """
  Handle the conn struct after processing
  """
  def handle_conn(conn, state) do
    conn
    |> send_options(state)
    |> send_lines(state)
    |> send_events()

    session = Map.merge(state.session, conn.session)
    state = Map.put(state, :session, session)

    case conn.private.halt? do
      true ->
        send(state.protocol, :terminate)
        {:noreply, state}

      false ->
        state
        |> update_character(conn)
        |> update_controller(conn)
    end
  end

  defp send_options(conn, state) do
    Enum.each(conn.options, fn option ->
      send(state.protocol, {:send, option})
    end)

    conn
  end

  defp send_lines(conn, state) do
    Enum.each(conn.lines, fn line ->
      send(state.protocol, {:send, line})
    end)

    conn
  end

  defp send_events(conn) do
    case Conn.event_router(conn) do
      nil ->
        conn

      event_router ->
        Enum.each(conn.events, fn event ->
          send(event_router, event)
        end)

        conn
    end
  end

  defp update_character(state, conn) do
    case is_nil(conn.update_character) do
      true ->
        state

      false ->
        state.presence_module.track(Conn.character(conn))
        %{state | character: conn.update_character}
    end
  end

  defp update_controller(state, conn) do
    case is_nil(conn.next_controller) do
      true ->
        {:noreply, state}

      false ->
        state = %{state | controller: conn.next_controller}
        {:noreply, state, {:continue, :init_controller}}
    end
  end
end
