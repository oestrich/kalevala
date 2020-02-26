defmodule Kantele.World.Character.Meta do
  @moduledoc """
  Specific metadata for a world character in Kantele
  """

  defstruct [:vitals, :zone_id]
end

defmodule Kantele.World.Character do
  @moduledoc "Callbacks for world run characters"

  @behaviour Kalevala.World.Character

  alias Kalevala.Character.Conn
  alias Kantele.Character.MoveEvent
  alias Kantele.World.Character.SpawnView

  @impl true
  def init(character), do: character

  @impl true
  def initialized(character), do: character

  @impl true
  def event(conn, _event), do: conn

  @impl true
  def spawn(conn) do
    character = conn.character

    conn
    |> Conn.move(:to, character.room_id, SpawnView, "spawn", %{})
    |> Conn.subscribe("rooms:#{character.room_id}", [], &MoveEvent.subscribe_error/2)
    |> Conn.event("room/look", %{})
  end
end

defmodule Kantele.World.Character.SpawnView do
  use Kalevala.Character.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("spawn", %{character: character}) do
    ~i(#{white()}#{character.name}#{reset()} spawned.)
  end
end
