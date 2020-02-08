defmodule Kalevala.World.ZoneSupervisor do
  @moduledoc "Supervisor to watch over Zones"

  use Supervisor

  alias Kalevala.World.RoomSupervisor
  alias Kalevala.World.Zone

  @doc false
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, [])
  end

  @impl true
  def init(config) do
    children = [
      {Zone, config},
      {RoomSupervisor, [name: RoomSupervisor.global_name(config.zone)]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
