defmodule Example.LookView do
  use Kalevala.View

  def render("look", _assigns) do
    "You are in a void.\n"
  end
end
