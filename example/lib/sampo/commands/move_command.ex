defmodule Sampo.MoveCommand do
  use Kalevala.Command

  def north(conn, _params) do
    conn
    |> event("movement/start", %{exit_name: "north"})
    |> assign(:prompt, false)
  end

  def south(conn, _params) do
    conn
    |> event("movement/start", %{exit_name: "south"})
    |> assign(:prompt, false)
  end

  def east(conn, _params) do
    conn
    |> event("movement/start", %{exit_name: "east"})
    |> assign(:prompt, false)
  end

  def west(conn, _params) do
    conn
    |> event("movement/start", %{exit_name: "west"})
    |> assign(:prompt, false)
  end
end
