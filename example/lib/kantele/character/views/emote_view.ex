defmodule Kantele.Character.EmoteView do
  use Kalevala.Character.View

  alias Kantele.Character.CharacterView

  def render("echo", %{character: character, text: text}) do
    ~i(#{CharacterView.render("name", %{character: character})} #{text}\n)
  end

  def render("list", %{emotes: emotes}) do
    available_emotes = Enum.map_join(emotes, "\n", &render("_emote", %{emote: &1}))

    ~E"""
    Emotes available:
    <%= available_emotes %>
    """
  end

  def render("_emote", %{emote: emote}) do
    ~i(- {color foreground="white"}#{emote}{/color})
  end

  def render("listen", %{character: character, text: text}) do
    ~i(#{CharacterView.render("name", %{character: character})} #{text}\n)
  end
end
