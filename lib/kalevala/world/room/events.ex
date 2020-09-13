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
