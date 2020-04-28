defmodule Kantele.World do
  @moduledoc """
  GenServer to load and boot the world
  """

  use Supervisor

  alias Kantele.World.Cache
  alias Kantele.World.Loader

  defstruct zones: [], rooms: [], characters: [], items: []

  @doc """
  Dereference a world variable reference
  """
  def dereference(reference) when is_binary(reference) do
    dereference(String.split(reference, "."))
  end

  def dereference([zone_id | reference]) do
    case :ets.lookup(Cache.ets_key(), zone_id) do
      [{^zone_id, zone}] ->
        Loader.dereference(zone, reference)

      _ ->
        :error
    end
  end

  @doc false
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_opts) do
    children = [
      {Kantele.World.Cache, [name: Kantele.World.Cache]},
      {Kantele.World.Items, [name: Kantele.World.Items]},
      {Kalevala.World, [name: Kantele.World]},
      {Kantele.World.Kickoff, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
