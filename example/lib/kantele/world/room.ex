defmodule Kantele.World.Room do
  @moduledoc """
  Callbacks for a Kalevala room
  """

  use Kalevala.World.Room

  require Logger

  alias Kantele.Communication
  alias Kantele.RoomChannel
  alias Kantele.World.Items
  alias Kantele.World.Room.Events

  @impl true
  def initialized(room) do
    options = [room_id: room.id]

    with {:error, _reason} <- Communication.register("rooms:#{room.id}", RoomChannel, options) do
      Logger.warn("Failed to register the room's channel, did the room restart?")

      :ok
    end
  end

  @impl true
  def event(context, event) do
    Events.call(context, event)
  end

  @impl true
  def load_item(item_instance), do: Items.get!(item_instance.item_id)

  @impl true
  def item_request_drop(_context, event, item_instance) do
    item = load_item(item_instance)

    has_drop_verb? =
      Enum.any?(item.verbs, fn verb ->
        verb.key == :drop
      end)

    case has_drop_verb? do
      true ->
        {:proceed, event, item_instance}

      false ->
        {:abort, event, :missing_verb}
    end
  end

  @impl true
  def item_request_pickup(_context, event, nil), do: {:abort, event, :no_item}

  def item_request_pickup(_context, event, item_instance) do
    item = load_item(item_instance)

    has_get_verb? =
      Enum.any?(item.verbs, fn verb ->
        verb.key == :get
      end)

    case has_get_verb? do
      true ->
        {:proceed, event, item_instance}

      false ->
        {:abort, event, :missing_verb, item_instance}
    end
  end
end

defmodule Kantele.World.Room.Events do
  @moduledoc false

  use Kalevala.Event.Router

  scope(Kantele.World.Room) do
    module(RandomExitEvent) do
      event("room/flee", :call)
      event("room/wander", :call)
    end

    module(ForwardEvent) do
      event("characters/emote", :call)
      event("characters/move", :call)
      event("combat/start", :call)
      event("combat/stop", :call)
      event("combat/tick", :call)
      event("commands/delayed", :call)
      event("inventory/list", :call)
    end

    module(LookEvent) do
      event("room/look", :call)
    end

    module(ContextEvent) do
      event("context/lookup", :call)
    end
  end
end

defmodule Kantele.World.Room.ForwardEvent do
  import Kalevala.World.Room.Context

  def call(context, event) do
    event(context, event.from_pid, self(), event.topic, event.data)
  end
end

defmodule Kantele.World.Room.RandomExitEvent do
  import Kalevala.World.Room.Context

  def call(context, event) do
    exits =
      Enum.map(context.data.exits, fn room_exit ->
        room_exit.exit_name
      end)

    event(context, event.from_pid, self(), event.topic, %{exits: exits})
  end
end

defmodule Kantele.World.Room.LookEvent do
  import Kalevala.World.Room.Context

  alias Kantele.Character.LookView
  alias Kantele.World.Items

  def call(context, event) do
    characters =
      Enum.reject(context.characters, fn character ->
        character.id == event.acting_character.id
      end)

    item_instances =
      Enum.map(context.item_instances, fn item_instance ->
        %{item_instance | item: Items.get!(item_instance.item_id)}
      end)

    context
    |> assign(:room, context.data)
    |> assign(:characters, characters)
    |> assign(:item_instances, item_instances)
    |> render(event.from_pid, LookView, "look", %{})
  end
end

defmodule Kantele.World.Room.ContextEvent do
  import Kalevala.World.Room.Context

  alias Kalevala.World.Item
  alias Kantele.Character.ContextView
  alias Kantele.World.Items

  def call(context, %{from_pid: from_pid, data: %{type: :item, id: item_id}}) do
    item_instance =
      Enum.find(context.item_instances, fn item_instance ->
        item_instance.item_id == item_id
      end)

    case item_instance != nil do
      true ->
        handle_context(context, from_pid, item_instance.item_id)

      false ->
        handle_unknown(context, from_pid, item_id)
    end
  end

  defp handle_unknown(context, from_pid, item_id) do
    context
    |> assign(:context, "room")
    |> assign(:id, item_id)
    |> render(from_pid, ContextView, "unknown")
  end

  defp handle_context(context, from_pid, item_id) do
    item = Items.get!(item_id)

    verbs = Item.context_verbs(item, %{location: "room"})

    context
    |> assign(:context, "room")
    |> assign(:item, item)
    |> assign(:verbs, verbs)
    |> render(from_pid, ContextView, "item")
  end
end

defmodule Kantele.World.Room.NotifyEvent do
  import Kalevala.World.Room.Context

  def call(context, event) do
    Enum.reduce(context.characters, context, fn character, context ->
      event(context, character.pid, event.from_pid, event.topic, event.data)
    end)
  end
end
