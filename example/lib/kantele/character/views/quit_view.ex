defmodule Kantele.Character.QuitView do
  use Kalevala.Character.View

  import IO.ANSI, only: [reset: 0, white: 0]

  # passed to actor disconnect
  def render("disconnected", %{character: character}) do
    ~i"#{white()}#{character.name}#{reset()} has left the game."
  end

  def render("goodbye", _assigns) do
    "Goodbye!\n"
  end
end
