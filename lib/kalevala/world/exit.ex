defmodule Kalevala.World.Exit do
  @moduledoc """
  Exits link rooms together in one exit_name

  To link rooms together, create exits in both exit_names
  """

  defstruct [:id, :exit_name, :start_room_id, :end_room_id]
end
