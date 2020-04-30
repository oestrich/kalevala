defmodule Kantele.Character.CommandView do
  use Kalevala.Character.View

  def render("prompt", %{character: character}) do
    %{vitals: vitals} = character.meta

    [
      "[",
      ~i({hp}#{vitals.health_points}/#{vitals.max_health_points}hp{/hp} ),
      ~i({sp}#{vitals.skill_points}/#{vitals.max_skill_points}sp{/hp} ),
      ~i({ep}#{vitals.endurance_points}/#{vitals.max_endurance_points}ep{/hp}),
      "] > "
    ]
  end

  def render("unknown", _assigns) do
    "What?\n"
  end
end
