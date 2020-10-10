defmodule Kalevala.World.CharacterSupervisor do
  @moduledoc "Supervisor to watch over Residents"

  use DynamicSupervisor

  @doc false
  def global_name(%{id: zone_id}), do: {:global, {__MODULE__, zone_id}}

  def global_name(zone_id), do: {:global, {__MODULE__, zone_id}}

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
