defmodule Kantele.World.Zone do
  @moduledoc """
  Callbacks for a Kalevala zone
  """

  defstruct [:id, :name, characters: [], rooms: [], items: []]

  @behaviour Kalevala.World.Zone

  @impl true
  def init(zone), do: zone
end
