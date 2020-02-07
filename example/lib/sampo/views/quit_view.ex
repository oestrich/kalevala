defmodule Sampo.QuitView do
  use Kalevala.View

  def render("goodbye", _assigns) do
    "Goodbye!\n"
  end
end
