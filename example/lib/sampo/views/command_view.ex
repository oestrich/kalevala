defmodule Sampo.CommandView do
  use Kalevala.View

  def render("prompt", _assigns) do
    "> "
  end

  def render("unknown", _assigns) do
    "What?\n"
  end
end
