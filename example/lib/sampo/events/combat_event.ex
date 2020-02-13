defmodule Sampo.CombatEvent do
  use Kalevala.Event

  alias Sampo.CharacterView
  alias Sampo.CombatView
  alias Sampo.CommandView
  alias Kalevala.Event

  def start(conn, _event) do
    event = %Event{
      from_pid: self(),
      topic: "combat/tick"
    }

    {:ok, timer} = :timer.send_interval(1_500, self(), {:route, event})

    conn
    |> render(CombatView, "tick", %{})
    |> render(CharacterView, "vitals", %{})
    |> prompt(CommandView, "prompt", %{})
    |> put_session(:combat_timer, timer)
  end

  def stop(conn, _event) do
    case get_session(conn, :combat_timer) do
      nil ->
        conn

      timer ->
        :timer.cancel(timer)

        put_session(conn, :combat_timer, nil)
    end
  end

  def tick(conn, _event) do
    meta = %{conn.character.meta | vitals: random_vitals(conn.character.meta.vitals)}
    character = %{conn.character | meta: meta}

    conn
    |> put_character(character)
    |> render(CombatView, "tick", %{})
    |> render(CharacterView, "vitals", %{})
    |> prompt(CommandView, "prompt", %{})
  end

  defp random_vitals(vitals) do
    %Sampo.Character.Vitals{
      health_points: :rand.uniform(vitals.max_health_points),
      max_health_points: vitals.max_health_points,
      skill_points: :rand.uniform(vitals.max_skill_points),
      max_skill_points: vitals.max_skill_points,
      endurance_points: :rand.uniform(vitals.max_endurance_points),
      max_endurance_points: vitals.max_endurance_points
    }
  end
end
