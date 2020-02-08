defmodule Kalevala.World.Room do
  @moduledoc """
  Rooms are the base unit of space in Kalevala
  """

  defstruct [:id, :zone_id, :name, :description, exits: []]
end
