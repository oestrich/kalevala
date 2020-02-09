defmodule Sampo.QuitView do
  use Kalevala.View

  import IO.ANSI, only: [reset: 0, white: 0]

  # passed to foreman disconnect
  def render("disconnected", %{character: character}) do
    ~i"#{white()}#{character.name}#{reset()} has left the game."
  end

  def render("goodbye", _assigns) do
    "Goodbye!\n"
  end
end
