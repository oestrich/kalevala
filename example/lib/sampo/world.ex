defmodule Sampo.World do
  @moduledoc """
  GenServer to load and boot the world
  """

  use GenServer

  alias Sampo.World.Loader

  @ets_key __MODULE__

  @doc """
  Dereference a world variable reference
  """
  def dereference(reference) when is_binary(reference) do
    dereference(String.split(reference, "."))
  end

  def dereference([zone_id | reference]) do
    case :ets.lookup(@ets_key, zone_id) do
      [{^zone_id, zone}] ->
        Loader.dereference(zone, reference)

      _ ->
        :error
    end
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    :ets.new(@ets_key, [:set, :protected, :named_table])

    {:ok, %{zones: []}, {:continue, :load}}
  end

  def handle_continue(:load, state) do
    zones = Loader.load_zones()

    zones
    |> Enum.map(&cache_zone/1)
    |> Enum.each(&Kalevala.World.start_zone/1)

    {:noreply, Map.put(state, :zones, zones)}
  end

  defp cache_zone(zone) do
    :ets.insert(@ets_key, {zone.id, zone})
    zone
  end
end
