defmodule Kantele.Character.CharacterView do
  use Kalevala.Character.View

  alias Kalevala.Character.Conn.Event

  def render("name", %{character: character}) do
    render("name", %{name: character.name})
  end

  def render("name", %{name: name}) do
    ~i({character}#{name}{/character})
  end

  def render("vitals", %{character: character}) do
    %Event{
      topic: "Character.Vitals",
      data: character.meta.vitals
    }
  end
end
