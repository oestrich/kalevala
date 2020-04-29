defmodule Kantele.Character.SayView do
  use Kalevala.Character.View

  alias Kantele.Character.CharacterView

  def render("text", %{text: text}) do
    ~i("{color foreground="green"}#{text}{/color}")
  end

  def render("echo", %{text: text}) do
    ~i(You say, #{render("text", %{text: text})}\n)
  end

  def render("listen", %{character_name: character_name, text: text}) do
    [
      CharacterView.render("name", %{name: character_name}),
      " says, ",
      render("text", %{text: text}),
      "\n"
    ]
  end
end
