defmodule Kalevala.World do
  @moduledoc """
  Manages the virtual world
  """

  require Logger

  @doc """
  Start the zone into the world
  """
  def start_zone(zone) do
    Logger.debug("Loading zone - #{inspect(zone)}")

    :ok
  end
end
