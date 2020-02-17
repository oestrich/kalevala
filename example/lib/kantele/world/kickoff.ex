defmodule Kantele.World.Kickoff do
  @moduledoc """
  Kicks off the world by loading and booting it
  """

  use GenServer

  alias Kantele.World.Cache
  alias Kantele.World.Loader

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
      supervisor: Kantele.World,
      callback_module: Kantele.World.Zone,
      rooms: %{
        callback_module: Kantele.World.Room
      }
    }

    Kalevala.World.start_zone(zone, config)
  end
end
