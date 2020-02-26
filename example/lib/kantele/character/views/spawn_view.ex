defmodule Kantele.Character.SpawnView do
  use Kalevala.Character.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("spawn", %{character: character}) do
    ~i(#{white()}#{character.name}#{reset()} spawned.)
  end
end
