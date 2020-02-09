defmodule Kalevala.Foreman do
  @moduledoc """
  Session Foreman

  Manages data flowing from the player into the game.
  """

  use GenServer

  require Logger

  alias Kalevala.Conn
  alias Kalevala.Event

  defstruct [:protocol, :controller, :options, session: %{}]

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
      controller: opts.initial_controller,
      options: %{}
    }

    {:ok, state, {:continue, :init_controller}}
  end

  @impl true
  def handle_continue(:init_controller, state) do
    %Conn{session: state.session}
    |> state.controller.init()
    |> handle_conn(state)
  end

  @impl true
  def handle_info({:recv, :text, data}, state) do
    %Conn{session: state.session}
    |> state.controller.recv(data)
    |> handle_conn(state)
  end

  def handle_info({:recv, :option, option}, state) do
    %Conn{session: state.session}
    |> state.controller.option(option)
    |> handle_conn(state)
  end

  def handle_info(event = %Event{}, state) do
    %Conn{session: state.session}
    |> state.controller.event(event)
    |> handle_conn(state)
  end

  def handle_info({:route, event = %Event{}}, state) do
    %Conn{session: state.session}
    |> Map.put(:events, [event])
    |> handle_conn(state)
  end

  def handle_info(event = %Event.Display{}, state) do
    event
    |> send_options(state)
    |> send_lines(state)

    {:noreply, state}
  end

  def handle_info(:terminate, state) do
    DynamicSupervisor.terminate_child(__MODULE__.Supervisor, self())
    {:noreply, state}
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
        case is_nil(conn.next_controller) do
          true ->
            {:noreply, state}

          false ->
            state = Map.put(state, :controller, conn.next_controller)

            {:noreply, state, {:continue, :init_controller}}
        end
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
end
