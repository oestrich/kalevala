defmodule Example.CommandView do
  use Kalevala.View

  def render("prompt", _assigns) do
    "> "
  end
end
