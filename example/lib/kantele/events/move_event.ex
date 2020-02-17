defmodule Kantele.MoveEvent do
  use Kalevala.Event

  alias Kantele.CommandView
  alias Kantele.MoveView

  def commit(conn, event) do
    conn
    |> move(:from, event.from, MoveView, "leave", %{})
    |> move(:to, event.to, MoveView, "enter", %{})
    |> put_character(%{conn.character | room_id: event.to})
    |> event("room/look")
  end

  def abort(conn, event) do
    conn
    |> render(MoveView, "fail", event)
    |> render(CommandView, "prompt")
  end
end
