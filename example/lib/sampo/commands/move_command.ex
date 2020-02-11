defmodule Sampo.MoveCommand do
  use Kalevala.Command

  def north(conn, _params) do
    conn
    |> event("movement/start", %{direction: "north"})
    |> assign(:prompt, false)
  end

  def south(conn, _params) do
    conn
    |> event("movement/start", %{direction: "south"})
    |> assign(:prompt, false)
  end

  def east(conn, _params) do
    conn
    |> event("movement/start", %{direction: "east"})
    |> assign(:prompt, false)
  end

  def west(conn, _params) do
    conn
    |> event("movement/start", %{direction: "west"})
    |> assign(:prompt, false)
  end
end
