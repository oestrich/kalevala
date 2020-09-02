defmodule Kantele.Character.ReloadView do
  use Kalevala.Character.View

  def render("recompiled", _assigns) do
    "Game code recompiled"
  end

  def render("reloaded", _assigns) do
    "Game world data reloaded!"
  end
end
