defmodule Kantele.Character.LookView do
  use Kalevala.Character.View

  alias Kalevala.Character.Conn.Event
  alias Kantele.Character.CharacterView
  alias Kantele.Character.ItemView

  def render("look.event", %{room: room}) do
    %Event{
      topic: "Room.Info",
      data: %{
        name: room.name,
        exits: Enum.map(room.exits, fn room_exit -> room_exit.exit_name end)
      }
    }
  end

  def render("look.text", %{room: room, characters: characters, item_instances: item_instances}) do
    ~E"""
    {room-title id="<%= room.id %>"}<%= room.name %>{/room-title}
    <%= render("_description", %{room: room}) %>
    <%= render("_items", %{item_instances: item_instances}) %>
    <%= render("_exits", %{room: room}) %>
    <%= render("_characters", %{characters: characters}) %>
    """
  end

  def render("_description", %{room: room}) do
    features =
      Enum.map(room.features, fn feature ->
        description = String.split(feature.short_description, feature.keyword)
        View.join(description, [~s({color foreground="white"}), feature.keyword, "{/color}"])
      end)

    description = [room.description] ++ features

    description
    |> Enum.reject(fn line -> line == "" end)
    |> View.join(" ")
  end

  def render("_exits", %{room: room}) do
    exits =
      room.exits
      |> Enum.map(fn room_exit ->
        ~i({color foreground="white"}#{room_exit.exit_name}{/color})
      end)
      |> View.join(" ")

    View.join(["Exits:", exits], " ")
  end

  def render("_characters", %{characters: []}), do: nil

  def render("_characters", %{characters: characters}) do
    characters =
      characters
      |> Enum.map(&render("_character", %{character: &1}))
      |> View.join("\n")

    View.join(["You see:", characters], "\n")
  end

  def render("_character", %{character: character}) do
    ~i(- #{CharacterView.render("name", %{character: character})})
  end

  def render("_items", %{item_instances: []}), do: nil

  def render("_items", %{item_instances: item_instances}) do
    items =
      item_instances
      |> Enum.map(&ItemView.render("name", %{item_instance: &1}))
      |> View.join(", ")

    View.join(["Items:", items], " ")
  end
end
