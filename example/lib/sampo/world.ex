defmodule Sampo.World do
  @moduledoc """
  GenServer to load and boot the world
  """

  use GenServer

  alias Sampo.World.Loader

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, %{}, {:continue, :load}}
  end

  def handle_continue(:load, state) do
    Enum.each(Loader.load_zones(), &Kalevala.World.start_zone/1)

    {:noreply, state}
  end
end
