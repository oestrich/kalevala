defmodule Kantele.World.Room do
  @moduledoc """
  Callbacks for a Kalevala room
  """

  use Kalevala.World.Room

  require Logger

  alias Kalevala.Verb
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
  def item_request_pickup(context, event, nil) do
    item_instance =
      Enum.find(context.item_instances, fn item_instance ->
        item_instance.id == event.data.item_name
      end)

    case item_instance != nil do
      true ->
        item_request_pickup(context, event, item_instance)

      false ->
        {:abort, event, :no_item, nil}
    end
  end

  def item_request_pickup(_context, event, item_instance) do
    item = load_item(item_instance)

    case Verb.has_matching_verb?(item.verbs, :get, %Verb.Context{location: "room"}) do
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

    module(TellEvent) do
      event("tell/send", :call)
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

  alias Kalevala.Verb
  alias Kalevala.World.Item
  alias Kantele.Character.ContextView
  alias Kantele.World.Items

  def call(context, %{from_pid: from_pid, data: %{type: :item, id: id}}) do
    item_instance =
      Enum.find(context.item_instances, fn item_instance ->
        item_instance.id == id
      end)

    case item_instance != nil do
      true ->
        handle_context(context, from_pid, item_instance)

      false ->
        handle_unknown(context, from_pid, id)
    end
  end

  defp handle_unknown(context, from_pid, id) do
    context
    |> assign(:context, "room")
    |> assign(:type, "item")
    |> assign(:id, id)
    |> render(from_pid, ContextView, "unknown")
  end

  defp handle_context(context, from_pid, item_instance) do
    item = Items.get!(item_instance.item_id)
    item_instance = %{item_instance | item: item}

    verbs = Item.context_verbs(item, %{location: "room"})
    verbs = Verb.replace_variables(verbs, %{id: item_instance.id})

    context
    |> assign(:context, "room")
    |> assign(:item_instance, item_instance)
    |> assign(:verbs, verbs)
    |> render(from_pid, ContextView, "item")
  end
end

defmodule Kantele.World.Room.TellEvent do
  import Kalevala.World.Room.Context

  def call(context, event) do
    name = event.data.name
    character = find_local_character(context, name) || find_player_character(name)
    data = Map.put(event.data, :character, character)
    event(context, event.from_pid, self(), event.topic, data)
  end

  defp find_local_character(context, name) do
    find_character(context.characters, name)
  end

  defp find_player_character(name) do
    characters = Kantele.Character.Presence.characters()
    find_character(characters, name)
  end

  defp find_character(characters, name) do
    Enum.find(characters, fn character ->
      Kalevala.Character.matches?(character, name)
    end)
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
