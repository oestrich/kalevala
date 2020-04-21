defmodule Kantele.World.Kickoff do
  @moduledoc """
  Kicks off the world by loading and booting it
  """

  use GenServer

  alias Kantele.World.Cache
  alias Kantele.World.Loader

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, %{}, {:continue, :load}}
  end

  def handle_continue(:load, state) do
    world = Loader.load_world()

    Enum.each(world.zones, fn zone ->
      zone
      |> Cache.cache_zone()
      |> Loader.strip_zone()
      |> start_zone()
    end)

    Enum.each(world.rooms, &start_room/1)
    Enum.each(world.characters, &start_character/1)
    Enum.each(world.items, &cache_item/1)

    {:noreply, state}
  end

  defp start_zone(zone) do
    config = %{
      supervisor_name: Kantele.World,
      callback_module: Kantele.World.Zone
    }

    Kalevala.World.start_zone(zone, config)
  end

  defp start_room(room) do
    config = %{
      supervisor_name: Kalevala.World.RoomSupervisor.global_name(room),
      callback_module: Kantele.World.Room
    }

    item_instances = Map.get(room, :item_instances, [])
    room = Map.delete(room, :item_instances)

    Kalevala.World.start_room(room, item_instances, config)
  end

  defp start_character(character) do
    config = [
      supervisor_name: Kalevala.World.CharacterSupervisor.global_name(character.meta.zone_id),
      character_module: Kantele.Character,
      communication_module: Kantele.Communication,
      initial_controller: Kantele.Character.SpawnController
    ]

    Kalevala.World.start_character(character, config)
  end

  defp cache_item(item) do
    Kantele.World.Items.put(item.id, item)
  end
end
