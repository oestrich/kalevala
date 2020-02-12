defmodule Sampo.MoveView do
  use Kalevala.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("enter", %{character: character}) do
    ~i(#{white()}#{character.name}#{reset()} enters.)
  end

  def render("leave", %{character: character}) do
    ~i(#{white()}#{character.name}#{reset()} leaves.)
  end

  def render("fail", %{reason: :no_exit, exit_name: exit_name}) do
    ~i(There is no exit #{exit_name}.\n)
  end
end
