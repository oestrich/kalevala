defmodule Kantele.CharacterView do
  use Kalevala.View

  alias Kalevala.Conn.Event

  def render("vitals", %{character: character}) do
    %Event{
      topic: "Character.Vitals",
      data: character.meta.vitals
    }
  end
end
