defmodule Sampo.MoveEvent do
  use Kalevala.Event

  alias Sampo.CommandView
  alias Sampo.MoveView

  def commit(conn, event) do
    conn
    |> move(:from, conn.character.room_id, MoveView, "leave", %{})
    |> move(:to, event.data.room_id, MoveView, "enter", %{})
    |> put_character(%{conn.character | room_id: event.data.room_id})
    |> event("room/look")
  end

  def fail(conn, event) do
    conn
    |> render(MoveView, "fail", event.data)
    |> render(CommandView, "prompt")
  end
end
