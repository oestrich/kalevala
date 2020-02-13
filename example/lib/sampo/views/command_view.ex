defmodule Sampo.CommandView do
  use Kalevala.View

  def render("prompt", %{character: character}) do
    %{vitals: vitals} = character.meta

    [
      "[",
      ~i(#{vitals.health_points}/#{vitals.max_health_points}hp ),
      ~i(#{vitals.skill_points}/#{vitals.max_skill_points}sp ),
      ~i(#{vitals.endurance_points}/#{vitals.max_endurance_points}ep),
      "] > "
    ]
  end

  def render("unknown", _assigns) do
    "What?\n"
  end
end
