defmodule Kantele.CombatCommand do
  use Kalevala.Command

  alias Kantele.CombatView

  def start(conn, _params) do
    conn
    |> render(CombatView, "start")
    |> event("combat/start")
  end

  def stop(conn, _params) do
    conn
    |> render(CombatView, "stop")
    |> event("combat/stop")
  end

  def tick(conn, _params) do
    render(conn, CombatView, "tick")
  end
end
