defmodule Kantele.World.Character.Meta do
  @moduledoc """
  Specific metadata for a world character in Kantele
  """

  defstruct [:vitals, :zone_id]
end

defmodule Kantele.World.Character do
  @moduledoc "Callbacks for world run characters"

  @behaviour Kalevala.World.Character

  @impl true
  def init(character), do: character

  @impl true
  def initialized(character), do: character

  @impl true
  def event(conn, _event), do: conn
end
