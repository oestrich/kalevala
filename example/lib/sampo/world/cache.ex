defmodule Sampo.World.Cache do
  @moduledoc """
  Cache for world data
  """

  use GenServer

  @ets_key __MODULE__

  def ets_key(), do: @ets_key

  def cache_zone(pid \\ __MODULE__, zone) do
    GenServer.call(pid, {:cache_zone, zone})
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    :ets.new(@ets_key, [:set, :protected, :named_table])

    {:ok, %{}}
  end

  def handle_call({:cache_zone, zone}, _from, state) do
    :ets.insert(@ets_key, {zone.id, zone})

    {:reply, zone, state}
  end
end
