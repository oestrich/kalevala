defmodule Kalevala.World.Room.Events do
  @moduledoc """
  Module for handling room events
  """

  alias Kalevala.Event
  alias Kalevala.World.Room
  alias Kalevala.World.Room.Context
  alias Kalevala.World.Room.Handler
  alias Kalevala.World.Room.Item
  alias Kalevala.World.Room.Movement

  @doc """
  Process events in a room
  """
  # Forward movement requests to the zone to handle
  def handle_event(event = %Event{topic: Event.Movement.Request}, state) do
    room_exit =
      Enum.find(Handler.exits(state), fn exit ->
        exit.exit_name == event.data.exit_name
      end)

    state
    |> Handler.movement_request(event, room_exit)
    |> Movement.handle_request(state, event.metadata)

    {:noreply, state}
  end

  def handle_event(event = %Event{topic: Event.Movement}, state) do
    case event.data.room_id == state.data.id do
      true ->
        state = Movement.handle_event(state, event)
        {:noreply, state}

      false ->
        Room.global_name(event.data.room_id)
        |> GenServer.whereis()
        |> send(event)

        {:noreply, state}
    end
  end

  def handle_event(event = %Event{topic: Event.ItemDrop.Request}, state) do
    %{item_instance: item_instance} = event.data

    state =
      state
      |> Handler.item_request_drop(event, item_instance)
      |> Item.handle_drop_request(state, event.metadata)

    {:noreply, state}
  end

  def handle_event(event = %Event{topic: Event.ItemPickUp.Request}, state) do
    %{item_name: item_name} = event.data

    item_instance =
      Enum.find(state.private.item_instances, fn item_instance ->
        item = Handler.load_item(state, item_instance)
        item.callback_module.matches?(item, item_name)
      end)

    state =
      state
      |> Handler.item_request_pickup(event, item_instance)
      |> Item.handle_pickup_request(state, event.metadata)

    {:noreply, state}
  end

  def handle_event(event = %Event{}, state) do
    context =
      state
      |> Handler.event(event)
      |> Context.handle_context()

    state = Map.put(state, :data, context.data)

    {:noreply, state}
  end
end

defmodule Kalevala.World.Room.Item do
  @moduledoc """
  Handle item pickup
  """

  alias Kalevala.Event
  alias Kalevala.Event.ItemDrop
  alias Kalevala.Event.ItemPickUp

  @doc """
  Handle a request for dropping an item
  """
  def handle_drop_request({:abort, event, reason}, state, metadata) do
    character = event.acting_character

    event = %Event{
      from_pid: self(),
      topic: ItemDrop.Abort,
      metadata: metadata,
      data: %ItemDrop.Abort{
        from: state.data.id,
        item_instance: event.data.item_instance,
        reason: reason
      }
    }

    send(character.pid, event)

    state
  end

  def handle_drop_request({:proceed, event, item_instance}, state, metadata) do
    character = event.acting_character

    event = %Event{
      from_pid: self(),
      topic: ItemDrop.Commit,
      metadata: metadata,
      data: %ItemDrop.Commit{
        from: state.data.id,
        item_instance: item_instance
      }
    }

    send(character.pid, event)

    add_item_instance(state, item_instance)
  end

  @doc """
  Handle a request for picking up an item
  """
  def handle_pickup_request({:abort, event, reason, item_instance}, state, metadata) do
    character = event.acting_character

    event = %Event{
      from_pid: self(),
      topic: ItemPickUp.Abort,
      metadata: metadata,
      data: %ItemPickUp.Abort{
        item_name: event.data.item_name,
        item_instance: item_instance,
        from: state.data.id,
        reason: reason
      }
    }

    send(character.pid, event)

    state
  end

  def handle_pickup_request({:proceed, event, item_instance}, state, metadata) do
    character = event.acting_character

    event = %Event{
      from_pid: self(),
      topic: ItemPickUp.Commit,
      metadata: metadata,
      data: %ItemPickUp.Commit{
        from: state.data.id,
        item_name: event.data.item_name,
        item_instance: item_instance
      }
    }

    send(character.pid, event)

    remove_item_instance(state, item_instance)
  end

  defp add_item_instance(state, item_instance) do
    item_instances = [item_instance | state.private.item_instances]
    private = Map.put(state.private, :item_instances, item_instances)
    Map.put(state, :private, private)
  end

  defp remove_item_instance(state, item_instance) do
    item_instances =
      Enum.reject(state.private.item_instances, fn room_item_instance ->
        room_item_instance.id == item_instance.id
      end)

    private = Map.put(state.private, :item_instances, item_instances)
    Map.put(state, :private, private)
  end
end

defmodule Kalevala.World.Room.Movement do
  @moduledoc """
  Handle room movement
  """

  alias Kalevala.Event
  alias Kalevala.Event.Movement
  alias Kalevala.Event.Movement.Voting
  alias Kalevala.World.Zone

  @doc """
  Handle the movement request

  - If an abort, forward to the character
  - Otherwise, Forward to the zone
  """
  def handle_request({:abort, event, reason}, state, metadata) do
    %{character: character} = event.data

    event = %Event{
      from_pid: self(),
      topic: Voting,
      metadata: metadata,
      data: %Voting{
        aborted: true,
        character: character,
        from: state.data.id,
        exit_name: event.data.exit_name,
        reason: reason
      }
    }

    send(character.pid, Voting.abort(event))
  end

  def handle_request({:proceed, event, room_exit}, state, metadata) do
    %{character: character} = event.data

    event = %Event{
      from_pid: self(),
      topic: Voting,
      metadata: metadata,
      data: %Voting{
        character: character,
        from: state.data.id,
        to: room_exit.end_room_id,
        exit_name: room_exit.exit_name
      }
    }

    Zone.global_name(state.data.zone_id)
    |> GenServer.whereis()
    |> send(event)
  end

  @doc """
  Handle the movement event
  """
  def handle_event(state, event = %Event{topic: Movement, data: %{direction: :to}}) do
    state
    |> broadcast(event)
    |> append_character(event)
  end

  def handle_event(state, event = %Event{topic: Movement, data: %{direction: :from}}) do
    state
    |> reject_character(event)
    |> broadcast(event)
  end

  @doc """
  Broadcast the event to characters in the room
  """
  def broadcast(state, event) do
    event = %Kalevala.Event{
      acting_character: event.data.character,
      from_pid: event.from_pid,
      topic: Kalevala.Event.Movement.Notice,
      data: %Kalevala.Event.Movement.Notice{
        character: event.data.character,
        direction: event.data.direction,
        reason: event.data.reason
      }
    }

    Enum.each(state.private.characters, fn character ->
      send(character.pid, event)
    end)

    state
  end

  defp append_character(state, event) do
    characters = [event.data.character | state.private.characters]
    private = Map.put(state.private, :characters, characters)

    Map.put(state, :private, private)
  end

  defp reject_character(state, event) do
    characters =
      Enum.reject(state.private.characters, fn character ->
        character.id == event.data.character.id
      end)

    private = Map.put(state.private, :characters, characters)
    Map.put(state, :private, private)
  end
end
