defmodule Example.CombatView do
  use Kalevala.View

  import IO.ANSI, only: [reset: 0, yellow: 0]

  def render("start", _assigns) do
    ~i"Starting combat\n"
  end

  def render("stop", _assigns) do
    ~i"Stopping combat\n"
  end

  def render("tick", _assigns) do
    ~i"""
    You attack the #{yellow()}enemy#{reset()}.
    The #{yellow()}enemy#{reset()} attacks you.
    """
  end
end
