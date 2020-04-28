defmodule Kantele.Character.EmoteView do
  use Kalevala.Character.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("echo", %{character: character, text: text}) do
    ~i(#{white()}#{character.name}#{reset()} #{text}\n)
  end

  def render("list", %{emotes: emotes}) do
    available_emotes =
      emotes
      |> Enum.map(&render("_emote", %{emote: &1}))
      |> Enum.join("\n")

    ~E"""
    Emotes available:
    <%= available_emotes %>
    """
  end

  def render("_emote", %{emote: emote}) do
    ~i(- #{white()}#{emote}#{reset()})
  end

  def render("listen", %{character_name: character_name, text: text}) do
    ~i(#{white()}#{character_name}#{reset()} #{text}\n)
  end
end
