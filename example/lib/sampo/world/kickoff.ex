defmodule Sampo.World.Kickoff do
  @moduledoc """
  Kicks off the world by loading and booting it
  """

  use GenServer

  alias Sampo.World.Cache
  alias Sampo.World.Loader

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, %{}, {:continue, :load}}
  end

  def handle_continue(:load, state) do
    zones = Loader.load_zones()

    zones
    |> Enum.map(&Cache.cache_zone/1)
    |> Enum.each(&start_zone/1)

    {:noreply, state}
  end

  defp start_zone(zone) do
    config = %{
      supervisor: Sampo.World,
      callback_module: Sampo.World.Zone,
      rooms: %{
        callback_module: Sampo.World.Room
      }
    }

    Kalevala.World.start_zone(zone, config)
  end
end
