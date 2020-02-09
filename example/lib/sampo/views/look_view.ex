defmodule Sampo.LookView do
  use Kalevala.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("look", %{room: room, characters: characters}) do
    ~E"""
    <%= white() %><%= room.name %><%= reset() %>
    <%= room.description %>

    You see:
    <%= render("_characters", %{characters: characters}) %>
    """
  end

  def render("_characters", %{characters: characters}) do
    characters
    |> Enum.map(&render("_character", %{character: &1}))
    |> View.join("\n")
  end

  def render("_character", %{character: character}) do
    ~i(- #{white()}#{character.name}#{reset()})
  end
end
