defmodule Kantele.Character.CharacterView do
  use Kalevala.Character.View

  alias Kalevala.Character.Conn.Event

  def render("vitals", %{character: character}) do
    %Event{
      topic: "Character.Vitals",
      data: character.meta.vitals
    }
  end
end
