defmodule Kantele.Character.SayView do
  use Kalevala.Character.View

  alias Kalevala.Character.Conn.EventText
  alias Kantele.Character.CharacterView

  def render("text", %{text: text}) do
    ~i("{text}#{text}{/text}")
  end

  def render("echo", %{text: text}) do
    %EventText{
      topic: "Room.Say",
      data: %{
        text: text
      },
      text: ~i(You say, #{render("text", %{text: text})}\n)
    }
  end

  def render("listen", %{character: character, id: id, text: text}) do
    %EventText{
      topic: "Room.Say",
      data: %{
        character: character,
        id: id,
        text: text
      },
      text: [
        CharacterView.render("name", %{character: character}),
        " says, #{render("text", %{text: text})}\n"
      ]
    }
  end
end
