defmodule Kalevala.World do
  @moduledoc """
  Manages the virtual world
  """

  require Logger

  use DynamicSupervisor

  alias Kalevala.Character.Foreman
  alias Kalevala.World.Room
  alias Kalevala.World.Zone
  alias Kalevala.World.ZoneSupervisor

  @doc """
  Start the zone into the world
  """
  def start_zone(zone, config) do
    options = %{
      zone: zone,
      config: config,
      genserver_options: [name: Zone.global_name(zone)]
    }

    DynamicSupervisor.start_child(config.supervisor_name, {ZoneSupervisor, options})
  end

  @doc """
  Start the room into the world
  """
  def start_room(room, item_instances, config) do
    options = %{
      room: room,
      item_instances: item_instances,
      config: config,
      genserver_options: [name: Room.global_name(room)]
    }

    DynamicSupervisor.start_child(config.supervisor_name, {Room, options})
  end

  @doc """
  Start a world character into the world
  """
  def start_character(character, config) do
    options = Keyword.merge(config, character: character)
    Foreman.start_non_player(options)
  end

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
