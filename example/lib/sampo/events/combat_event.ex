defmodule Sampo.CombatEvent do
  use Kalevala.Event

  alias Sampo.CharacterView
  alias Sampo.CombatView
  alias Sampo.CommandView
  alias Kalevala.Event

  def start(conn, _event) do
    {:ok, timer} = :timer.send_interval(1_500, self(), %Event{topic: "combat/tick"})

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
    conn
    |> render(CombatView, "tick", %{})
    |> render(CharacterView, "vitals", %{})
    |> prompt(CommandView, "prompt", %{})
  end
end
