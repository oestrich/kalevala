defmodule Kantele.Character.SayView do
  use Kalevala.Character.View

  alias Kantele.Character.CharacterView

  def render("text", %{text: text}) do
    ~i("{text}#{text}{/text}")
  end

  def render("echo", %{text: text}) do
    ~i(You say, #{render("text", %{text: text})}\n)
  end

  def render("listen", %{character: character, text: text}) do
    [
      CharacterView.render("name", %{character: character}),
      " says, #{render("text", %{text: text})}\n"
    ]
  end
end
