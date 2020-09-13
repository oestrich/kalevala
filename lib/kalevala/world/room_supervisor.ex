defmodule Kalevala.World.RoomSupervisor do
  @moduledoc "Supervisor to watch over Rooms"

  use DynamicSupervisor

  alias Kalevala.World.Zone

  @doc false
  def global_name(zone = %Zone{}), do: {:global, {__MODULE__, zone.id}}

  def global_name(zone_child), do: {:global, {__MODULE__, Zone.Child.zone_id(zone_child)}}

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
