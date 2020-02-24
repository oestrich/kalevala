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

    world.zones
    |> Enum.map(&Cache.cache_zone/1)
    |> Enum.each(&start_zone/1)

    Enum.each(world.rooms, &start_room/1)
    Enum.each(world.characters, &start_character/1)

    {:noreply, state}
  end

  defp start_zone(zone) do
    config = %{
      supervisor: Kantele.World,
      callback_module: Kantele.World.Zone
    }

    Kalevala.World.start_zone(zone, config)
  end

  defp start_room(room) do
    config = %{
      supervisor: Kalevala.World.RoomSupervisor.global_name(room),
      callback_module: Kantele.World.Room
    }

    Kalevala.World.start_room(room, config)
  end

  defp start_character(character) do
    config = %{
      supervisor: Kalevala.World.CharacterSupervisor.global_name(character.meta.zone_id),
      callback_module: Kantele.World.Character
    }

    Kalevala.World.start_character(character, config)
  end
end
