defmodule Kalevala.Character.Foreman do
  @moduledoc """
  Session Foreman

  Manages data flowing from the player into the game.
  """

  use GenServer

  require Logger

  alias Kalevala.Character.Conn
  alias Kalevala.Event
  alias Kalevala.Character.Foreman.Channel

  @type t() :: %__MODULE__{}

  defstruct [
    :callback_module,
    :character,
    :communication_module,
    :controller,
    :supervisor_name,
    processing_action: nil,
    action_queue: [],
    private: %{},
    session: %{},
    flash: %{}
  ]

  @doc """
  Start a new foreman for a connecting player
  """
  def start_player(protocol_pid, options) do
    options =
      Keyword.merge(options,
        callback_module: Kalevala.Character.Foreman.Player,
        protocol: protocol_pid
      )

    DynamicSupervisor.start_child(options[:supervisor_name], {__MODULE__, options})
  end

  @doc """
  Start a new foreman for a non-player (character run by the world)
  """
  def start_non_player(options) do
    options = Keyword.merge(options, callback_module: Kalevala.Character.Foreman.NonPlayer)
    DynamicSupervisor.start_child(options[:supervisor_name], {__MODULE__, options})
  end

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @impl true
  def init(opts) do
    opts = Enum.into(opts, %{})

    state = %__MODULE__{
      callback_module: opts.callback_module,
      communication_module: opts.communication_module,
      controller: opts.initial_controller,
      supervisor_name: opts.supervisor_name
    }

    state = opts.callback_module.init(state, opts)

    {:ok, state, {:continue, :init_controller}}
  end

  @doc false
  def new_conn(state) do
    %Conn{
      character: state.character,
      session: state.session,
      flash: state.flash,
      private: %Conn.Private{
        request_id: Conn.Private.generate_request_id()
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

  def handle_info({:recv, :event, event}, state) do
    new_conn(state)
    |> state.controller.recv_event(event)
    |> handle_conn(state)
  end

  def handle_info(event = %Event{}, state) do
    new_conn(state)
    |> state.controller.event(event)
    |> handle_conn(state)
  end

  def handle_info({:route, event = %Event{}}, state) do
    new_conn(state)
    |> Map.put(:events, [event])
    |> handle_conn(state)
  end

  def handle_info(event = %Event.Delayed{}, state) do
    event = Event.Delayed.to_event(event)

    new_conn(state)
    |> Map.put(:events, [event])
    |> handle_conn(state)
  end

  def handle_info(event = %Event.Display{}, state) do
    new_conn(state)
    |> state.controller.display(event)
    |> handle_conn(state)
  end

  def handle_info({:process_action, action}, state) do
    case state.processing_action == action do
      true ->
        Logger.info(
          "Processing #{inspect(action.type)}, #{Enum.count(state.action_queue)} left in the queue.",
          request_id: action.request_id
        )

        state = Map.put(state, :processing_action, nil)

        new_conn(state)
        |> action.type.run(action.params)
        |> handle_conn(state)

      false ->
        Logger.warning("Character tried processing an action that was not next", type: :foreman)

        {:noreply, state}
    end
  end

  def handle_info(:terminate, state) do
    state.callback_module.terminating(state)
    DynamicSupervisor.terminate_child(state.supervisor_name, self())
    {:noreply, state}
  end

  @doc """
  Handle the conn struct after processing
  """
  def handle_conn(conn, state) do
    conn
    |> Channel.handle_channels(state)
    |> send_options(state)
    |> send_output(state)
    |> send_events()

    session = Map.merge(state.session, conn.session)
    flash = Map.merge(state.flash, conn.flash)

    state =
      state
      |> Map.put(:session, session)
      |> Map.put(:flash, flash)
      |> Map.put(:action_queue, state.action_queue ++ conn.private.actions)

    case conn.private.halt? do
      true ->
        state.callback_module.terminate(state)
        {:noreply, state}

      false ->
        state
        |> handle_actions()
        |> update_character(conn)
        |> update_controller(conn)
    end
  end

  defp handle_actions(state = %{processing_action: nil, action_queue: [action | actions]}) do
    Logger.info(
      "Delaying #{inspect(action.type)} for #{action.delay}ms with #{inspect(action.params)}",
      request_id: action.request_id
    )

    Process.send_after(self(), {:process_action, action}, action.delay)

    state
    |> Map.put(:processing_action, action)
    |> Map.put(:action_queue, actions)
  end

  defp handle_actions(state), do: state

  defp send_options(conn, state) do
    state.callback_module.send_options(state, conn.options)

    conn
  end

  defp send_output(conn, state) do
    state.callback_module.send_output(state, conn.output)

    conn
  end

  @doc false
  def send_events(conn) do
    {events, delayed_events} =
      Enum.split_with(conn.events, fn event ->
        match?(%Kalevala.Event{}, event)
      end)

    Enum.each(delayed_events, fn delayed_event ->
      Process.send_after(self(), delayed_event, delayed_event.delay)
    end)

    case Conn.event_router(conn) do
      nil ->
        conn

      event_router ->
        Enum.each(events, fn event ->
          send(event_router, event)
        end)

        conn
    end
  end

  defp update_character(state, conn) do
    case is_nil(conn.private.update_character) do
      true ->
        state

      false ->
        state.callback_module.track_presence(state, conn)
        %{state | character: conn.private.update_character}
    end
  end

  defp update_controller(state, conn) do
    case is_nil(conn.private.next_controller) do
      true ->
        {:noreply, state}

      false ->
        state =
          state
          |> Map.put(:controller, conn.private.next_controller)
          |> Map.put(:flash, conn.private.next_controller_flash)

        {:noreply, state, {:continue, :init_controller}}
    end
  end
end

defmodule Kalevala.Character.Foreman.Callbacks do
  @moduledoc """
  Callbacks for a integrating with the character foreman process
  """

  alias Kalevala.Character.Conn
  alias Kalevala.Character.Foreman

  @type state() :: Foreman.t()

  @typedoc "Options for starting the foreman process"
  @type opts() :: Keyword.t()

  @doc """
  Fill in state with any passed in options
  """
  @callback init(state(), opts()) :: state()

  @doc """
  Called when the foreman process is halted through a conn

  Perform whatever actions are required to start terminating.
  """
  @callback terminate(state()) :: :ok

  @doc """
  The process is terminating from a `:terminate` message

  Perform whatever is required before terminating.
  """
  @callback terminating(state()) :: :ok

  @doc """
  Send options to a connection process
  """
  @callback send_options(state(), list()) :: :ok

  @doc """
  Send text to a connection process
  """
  @callback send_output(state(), list()) :: :ok

  @doc """
  The character updated and presence should be tracked
  """
  @callback track_presence(state, Conn.t()) :: :ok
end

defmodule Kalevala.Character.Foreman.Player do
  @moduledoc """
  Callbacks for a player character
  """

  alias Kalevala.Character.Conn
  alias Kalevala.Character.Foreman
  alias Kalevala.Event

  @behaviour Kalevala.Character.Foreman.Callbacks

  defstruct [:protocol, :presence_module, :quit_view]

  @impl true
  def init(state, opts) do
    private = %__MODULE__{
      protocol: opts.protocol,
      presence_module: opts.presence_module,
      quit_view: opts.quit_view
    }

    %{state | private: private}
  end

  @impl true
  def terminate(state) do
    send(state.private.protocol, :terminate)
  end

  @impl true
  def terminating(%{character: nil}), do: :ok

  def terminating(state) do
    {quit_view, quit_template} = state.private.quit_view

    conn = Foreman.new_conn(state)

    event = %Event{
      topic: Event.Movement,
      data: %Event.Movement{
        character: Conn.Private.character(conn),
        direction: :from,
        reason: quit_view.render(quit_template, %{character: state.character}),
        room_id: state.character.room_id
      }
    }

    conn
    |> Map.put(:events, [event])
    |> Foreman.send_events()
  end

  @impl true
  def send_options(state, options) do
    Enum.each(options, fn option ->
      send(state.private.protocol, {:send, option})
    end)
  end

  @impl true
  def send_output(state, text) do
    Enum.each(text, fn line ->
      send(state.private.protocol, {:send, line})
    end)
  end

  @impl true
  def track_presence(state, conn) do
    state.private.presence_module.track(Conn.character(conn, trim: true))
  end
end

defmodule Kalevala.Character.Foreman.NonPlayer do
  @moduledoc """
  Callbacks for a non-player character
  """

  require Logger

  alias Kalevala.Character.Conn
  alias Kalevala.Character.Foreman
  alias Kalevala.Event

  @behaviour Kalevala.Character.Foreman.Callbacks

  defstruct [:quit_view]

  @impl true
  def init(state, opts) do
    Logger.info("Character starting - #{opts.character.id}")

    private = %__MODULE__{
      quit_view: opts.quit_view
    }

    %{state | character: %{opts.character | pid: self()}, private: private}
  end

  @impl true
  def terminate(state), do: state

  @impl true
  def terminating(%{character: nil}), do: :ok

  def terminating(state) do
    {quit_view, quit_template} = state.private.quit_view

    conn = Foreman.new_conn(state)

    event = %Event{
      topic: Event.Movement,
      data: %Event.Movement{
        character: Conn.Private.character(conn),
        direction: :from,
        reason: quit_view.render(quit_template, %{character: state.character}),
        room_id: state.character.room_id
      }
    }

    conn
    |> Map.put(:events, [event])
    |> Foreman.send_events()
  end

  @impl true
  def send_options(_state, _options), do: :ok

  @impl true
  def send_output(_state, _output), do: :ok

  @impl true
  def track_presence(_state, _conn), do: :ok
end
