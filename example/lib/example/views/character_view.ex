defmodule Example.CharacterView do
  use Kalevala.View

  alias Kalevala.Conn.Event

  def render("vitals", _assigns) do
    %Event{
      topic: "Character.Vitals",
      data: %{
        health_points: 50,
        max_health_points: 50
      }
    }
  end
end
