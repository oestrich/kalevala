defmodule Sampo.MoveView do
  use Kalevala.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("enter", %{character: character}) do
    ~i"#{white()}#{character.name}#{reset()} enters."
  end
end
