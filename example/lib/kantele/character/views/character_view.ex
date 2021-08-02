defmodule Kantele.Character.CharacterView do
  use Kalevala.Character.View

  alias Kalevala.Character.Conn.Event
  alias Kalevala.Character.Conn.EventText

  def render("name", %{character: character}) do
    ~i({character id="#{character.id}" name="#{character.name}" description="#{character.description}"}#{character.name}{/character})
  end

  def render("vitals", %{character: character}) do
    %Event{
      topic: "Character.Vitals",
      data: character.meta.vitals
    }
  end

  def render("character-name", _assigns) do
    %EventText{
      topic: "Login.PromptCharacter",
      data: %{},
      text: "What is your character name? "
    }
  end

  def render("enter-world", %{character: character}) do
    %EventText{
      topic: "Login.EnterWorld",
      data: %{
        character: %{
          name: character.name
        }
      },
      text: [
        ~s(Welcome to the world of {color foreground="256:39"}Kantele{/color}, {color foreground="yellow"}),
        character.name,
        ~s({/color}.\n)
      ]
    }
  end
end
