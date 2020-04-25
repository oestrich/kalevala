defmodule Kalevala.World.Room.Private do
  @moduledoc """
  Store private information for a room, e.g. characters in the room
  """

  defstruct characters: [], item_instances: []
end

defmodule Kalevala.World.Room.Feature do
  @moduledoc """
  A room feature is a highlighted part of a room
  """

  defstruct [:id, :keyword, :short_description, :description]
end

defmodule Kalevala.World.Room do
  @moduledoc """
  Rooms are the base unit of space in Kalevala
  """

  use GenServer

  require Logger

  alias Kalevala.Event
  alias Kalevala.Event.Message
  alias Kalevala.World
  alias Kalevala.World.Room.Context
  alias Kalevala.World.Room.Events
  alias Kalevala.World.Room.Exit
  alias Kalevala.World.Room.Private

  defstruct [
    :id,
    :zone_id,
    :name,
    :description,
    exits: [],
    features: []
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Called when the room is initializing
  """
  @callback init(room :: t()) :: t()

  @doc """
  Called after the room process is started

  Directly after `init` is completed.
  """
  @callback initialized(room :: t()) :: :ok

  @doc """
  Callback for when a new event is received
  """
  @callback event(Context.t(), event :: Event.t()) :: Context.t()

  @doc """
  Callback for the room to hook into movement between exits

  The character is requesting to move via an exit, a tuple allowing or rejecting
  the movement before being pitched up to the Zone should be returned.

  Can immediately terminate a room before being checked in a more detailed fashion
  with `confirm_movement/2` below.
  """
  @callback movement_request(Context.t(), Event.movement_request(), Exit.t() | nil) ::
              {:abort, event :: Event.t(), reason :: atom()}
              | {:proceed, event :: Event.t(), room_exit :: Exit.t()}

  @doc """
  Callback for confirming or aborting character movement

  Called while the Zone is checking each side of the exit to know if the movement
  is indeed allowed. Returning the original event allows movement to proceed, otherwise
  return an aborted event to prevent movement.

  Hook to allow for the room to reject movement for custom reasons, e.g. an NPC
  is blocking the exit and needs to be convinced first, or there is a trap blocking
  the exit.
  """
  @callback confirm_movement(Context.t(), event :: Event.movement_voting()) ::
              {Context.t(), Event.movement_voting()}

  @doc """
  Convert item instances into items
  """
  @callback load_item(World.Item.Instance.t()) :: World.Item.t()

  @doc """
  Callback for allowing an item drop off

  A character is requesting to pick up an item, this let's the room
  accept or reject the request.
  """
  @callback item_request_drop(Context.t(), Event.item_request_drop(), World.Item.Instance.t()) ::
              {:abort, event :: Event.item_request_drop(), reason :: atom()}
              | {:proceed, event :: Event.item_request_drop(), World.Item.Instance.t()}

  @doc """
  Callback for allowing an item pick up

  A character is requesting to pick up an item, this let's the room
  accept or reject the request.
  """
  @callback item_request_pickup(Context.t(), Event.item_request_pickup(), World.Item.Instance.t()) ::
              {:abort, event :: Event.item_request_pickup(), reason :: atom()}
              | {:proceed, event :: Event.item_request_pickup(), World.Item.Instance.t()}

  defmacro __using__(_opts) do
    quote do
      import Kalevala.World.Room.Context

      @behaviour Kalevala.World.Room

      @impl true
      def init(room), do: room

      @impl true
      def movement_request(_context, event, nil), do: {:abort, event, :no_exit}

      def movement_request(_context, event, room_exit), do: {:proceed, event, room_exit}

      @impl true
      def confirm_movement(context, event), do: {context, event}

      @impl true
      def item_request_drop(_context, event, item_instance),
        do: {:proceed, event, item_instance}

      @impl true
      def item_request_pickup(_context, event, nil), do: {:abort, event, :no_item}

      def item_request_pickup(_context, event, item_instance),
        do: {:proceed, event, item_instance}

      defoverridable confirm_movement: 2, init: 1, movement_request: 3
    end
  end

  @doc """
  Confirm movement for a character
  """
  def confirm_movement(event = %Event{topic: Voting, data: %{aborted: true}}, _room_id) do
    event
  end

  def confirm_movement(event, room_id) do
    GenServer.call(global_name(room_id), event)
  end

  @doc false
  def global_name(room = %__MODULE__{}), do: global_name(room.id)

  def global_name(room_id), do: {:global, {__MODULE__, room_id}}

  @doc false
  def start_link(options) do
    genserver_options = options.genserver_options
    options = Map.delete(options, :genserver_options)

    GenServer.start_link(__MODULE__, options, genserver_options)
  end

  @impl true
  def init(options) do
    Logger.info("Room starting - #{options.room.id}")

    config = options.config
    room = config.callback_module.init(options.room)

    state = %{
      data: room,
      supervisor_name: config.supervisor_name,
      callback_module: config.callback_module,
      private: %Private{
        item_instances: options.item_instances
      }
    }

    {:ok, state, {:continue, :initialized}}
  end

  @impl true
  def handle_continue(:initialized, state) do
    state.callback_module.initialized(state.data)
    {:noreply, state}
  end

  @impl true
  def handle_call(event = %Event{topic: Event.Movement.Voting}, _from, state) do
    {context, event} =
      state
      |> Context.new()
      |> state.callback_module.confirm_movement(event)

    Context.handle_context(context)

    state = Map.put(state, :data, context.data)

    {:reply, event, state}
  end

  @impl true
  def handle_info(event = %Event{}, state) do
    Events.handle_event(event, state)
  end

  def handle_info(message = %Message{}, state) do
    context =
      Context.new(state)
      |> state.callback_module.event(message)
      |> Context.handle_context()

    state = Map.put(state, :data, context.data)

    {:noreply, state}
  end
end
