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
