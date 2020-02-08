defmodule Sampo.World.Room do
  @moduledoc """
  Callbacks for a Kalevala room
  """

  @behaviour Kalevala.World.Room

  @impl true
  def init(room), do: room
end
