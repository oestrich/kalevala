defmodule Kalevala.World do
  @moduledoc """
  Manages the virtual world
  """

  require Logger

  use DynamicSupervisor

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
      otp: [name: Zone.global_name(zone)]
    }

    DynamicSupervisor.start_child(config.supervisor, {ZoneSupervisor, options})
  end

  @doc """
  Start the room into the world
  """
  def start_room(room, config) do
    options = %{
      room: room,
      config: config,
      otp: [name: Room.global_name(room)]
    }

    DynamicSupervisor.start_child(config.supervisor, {Room, options})
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
