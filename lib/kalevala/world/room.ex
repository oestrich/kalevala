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
  alias Kalevala.World.Room.Callbacks
  alias Kalevala.World.Room.Context
  alias Kalevala.World.Room.Events
  alias Kalevala.World.Room.Handler
  alias Kalevala.World.Room.Private

  @doc """
  Confirm movement for a character
  """
  def confirm_movement(event = %Event{topic: Voting, data: %{aborted: true}}, _room_id) do
    event
  end

  def confirm_movement(event, room_id) do
    GenServer.call(global_name(room_id), event)
  end

  @doc """
  Replace internal room state
  """
  def update(pid, room) do
    GenServer.call(pid, {:update, room})
  end

  @doc """
  Replace internal room items state
  """
  def update_items(pid, item_instances) do
    GenServer.call(pid, {:update_items, item_instances})
  end

  @doc false
  def global_name(%{id: id}), do: global_name(id)

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
    room = Callbacks.init(options.room)

    state = %{
      data: room,
      supervisor_name: config.supervisor_name,
      private: %Private{
        item_instances: options.item_instances
      }
    }

    {:ok, state, {:continue, :initialized}}
  end

  @impl true
  def handle_continue(:initialized, state) do
    data = Callbacks.initialized(state.data)
    state = %{state | data: data}
    {:noreply, state}
  end

  @impl true
  def handle_call(event = %Event{topic: Event.Movement.Voting}, _from, state) do
    {context, event} = Handler.confirm_movement(state, event)

    Context.handle_context(context)

    state = Map.put(state, :data, context.data)

    {:reply, event, state}
  end

  def handle_call({:update, room}, _from, state) do
    state = %{state | data: room}
    {:reply, :ok, state}
  end

  def handle_call({:update_items, item_instances}, _from, state) do
    state = %{state | private: %{state.private | item_instances: item_instances}}
    {:reply, :ok, state}
  end

  @impl true
  def handle_info(event = %Event{}, state) do
    Events.handle_event(event, state)
  end

  def handle_info(message = %Message{}, state) do
    context =
      state
      |> Handler.event(message)
      |> Context.handle_context()

    state = Map.put(state, :data, context.data)

    {:noreply, state}
  end
end

defmodule Kalevala.World.Room.Handler do
  @moduledoc false

  alias Kalevala.World.Room.Callbacks
  alias Kalevala.World.Room.Context

  def event(state, event) do
    Callbacks.event(state.data, Context.new(state), event)
  end

  def match_character?(character, keyword) do
    Callbacks.match_character?(character, keyword)
  end

  # Items

  def load_item(state, item_instance) do
    Callbacks.load_item(state.data, item_instance)
  end

  def item_request_drop(state, event, item_instance) do
    Callbacks.item_request_drop(state.data, Context.new(state), event, item_instance)
  end

  def item_request_pickup(state, event, item_instance) do
    Callbacks.item_request_pickup(state.data, Context.new(state), event, item_instance)
  end

  # Movement

  def exits(state), do: Callbacks.exits(state.data)

  def movement_request(state, event, room_exit) do
    Callbacks.movement_request(state.data, Context.new(state), event, room_exit)
  end

  def confirm_movement(state, event) do
    Callbacks.confirm_movement(state.data, Context.new(state), event)
  end
end

defprotocol Kalevala.World.Room.Callbacks do
  @doc """
  Called when the room is initializing
  """
  def init(room)

  @doc """
  Called after the room process is started

  Directly after `init` is completed.
  """
  def initialized(room)

  @doc """
  Callback for when a new event is received
  """
  def event(room, context, event)

  @doc """
  Load the exits for a given room

  Used when a character is trying to move, the appropriate exit is chosen
  and forwarded into movement request callbacks. Since this is a common thing
  that will happen 99% of the time, Kalevala handles it.
  """
  def exits(room)

  @doc """
  Convert item instances into items
  """
  def load_item(room, item_instance)

  @doc """
  Callback for allowing an item drop off

  A character is requesting to pick up an item, this let's the room
  accept or reject the request.
  """
  def item_request_drop(room, context, item_request_drop, item_instance)

  @doc """
  Callback for allowing an item pick up

  A character is requesting to pick up an item, this let's the room
  accept or reject the request.
  """
  def item_request_pickup(room, context, item_request_pickup, item_instance)

  @doc """
  Callback for the room to hook into movement between exits

  The character is requesting to move via an exit, a tuple allowing or rejecting
  the movement before being pitched up to the Zone should be returned.

  Can immediately terminate a room before being checked in a more detailed fashion
  with `confirm_movement/2` below.
  """
  def movement_request(room, context, movement_request, room_exit)

  @doc """
  Callback for confirming or aborting character movement

  Called while the Zone is checking each side of the exit to know if the movement
  is indeed allowed. Returning the original event allows movement to proceed, otherwise
  return an aborted event to prevent movement.

  Hook to allow for the room to reject movement for custom reasons, e.g. an NPC
  is blocking the exit and needs to be convinced first, or there is a trap blocking
  the exit.
  """
  def confirm_movement(room, context, event)
end

defmodule Kalevala.World.BasicRoom do
  @moduledoc """
  A basic room

  These are the minimum fields a room should have. You likely want more, so
  we have a protocol `Kalevala.World.Room.Callbacks` to let you create your own
  local struct.

  The following functions provide default implementations you can use for the
  `defimpl` of that protocol.

  ```elixir
  defimpl Kalevala.World.Room.Callbacks do
    alias Kalevala.World.BasicRoom

    @impl true
    def movement_request(_room, context, event, room_exit),
      do: BasicRoom.movement_request(context, event, room_exit)

    @impl true
    def confirm_movement(_room, context, event),
      do: BasicRoom.confirm_movement(context, event)

    @impl true
    def item_request_drop(_room, context, event, item_instance),
      do: BasicRoom.item_request_drop(context, event, item_instance)

    @impl true
    def item_request_pickup(_room, context, event, item_instance),
      do: BasicRoom.item_request_pickup(context, event, item_instance)

    # ...
  end
  ```
  """

  defstruct [:id]

  def movement_request(_context, event, nil), do: {:abort, event, :no_exit}

  def movement_request(_context, event, room_exit), do: {:proceed, event, room_exit}

  def confirm_movement(context, event), do: {context, event}

  def item_request_drop(_context, event, item_instance),
    do: {:proceed, event, item_instance}

  def item_request_pickup(_context, event, nil), do: {:abort, event, :no_item, nil}

  def item_request_pickup(_context, event, item_instance),
    do: {:proceed, event, item_instance}
end
