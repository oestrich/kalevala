defmodule Kantele.Character.CommandView do
  use Kalevala.Character.View

  def render("prompt", %{character: character}) do
    %{vitals: vitals} = character.meta

    [
      "[",
      ~i({color foreground="red"}#{vitals.health_points}/#{vitals.max_health_points}hp{/color} ),
      ~i({color foreground="blue"}#{vitals.skill_points}/#{vitals.max_skill_points}sp{/color} ),
      ~i({color foreground="green"}#{vitals.endurance_points}/#{vitals.max_endurance_points}ep{/color}),
      "] > "
    ]
  end

  def render("unknown", _assigns) do
    "What?\n"
  end
end
