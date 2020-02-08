defmodule Kalevala.World.RoomSupervisor do
  @moduledoc "Supervisor to watch over Rooms"

  use DynamicSupervisor

  @doc false
  def global_name(zone), do: {:global, {__MODULE__, zone.id}}

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
