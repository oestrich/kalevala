defmodule Kalevala.World.Exit do
  @moduledoc """
  Exits link rooms together in one direction

  To link rooms together, create exits in both directions
  """

  defstruct [:id, :direction, :start_room_id, :end_room_id]
end
