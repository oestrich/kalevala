defmodule Kantele.Character.CombatView do
  use Kalevala.Character.View

  def render("start", _assigns) do
    ~i"Starting combat\n"
  end

  def render("stop", _assigns) do
    ~i"Stopping combat\n"
  end

  def render("tick", _assigns) do
    ~i"""
    You attack the {color foreground="yellow"}enemy{/color}.
    The {color foreground="yellow"}enemy{/color} attacks you.
    """
  end
end
