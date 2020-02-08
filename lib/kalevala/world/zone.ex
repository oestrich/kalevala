defmodule Kalevala.World.Zone do
  @moduledoc """
  Zones group together Rooms into a logical space
  """

  defstruct [:id, :name, rooms: []]
end
