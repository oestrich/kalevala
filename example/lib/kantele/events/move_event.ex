defmodule Kantele.MoveEvent do
  use Kalevala.Event

  require Logger

  alias Kantele.CommandView
  alias Kantele.MoveView

  def commit(conn, %{data: event}) do
    conn
    |> move(:from, event.from, MoveView, "leave", %{})
    |> move(:to, event.to, MoveView, "enter", %{})
    |> put_character(%{conn.character | room_id: event.to})
    |> unsubscribe("rooms:#{event.from}", [], &unsubscribe_error/2)
    |> subscribe("rooms:#{event.to}", [], &subscribe_error/2)
    |> event("room/look")
  end

  def abort(conn, %{data: event}) do
    conn
    |> render(MoveView, "fail", event)
    |> render(CommandView, "prompt")
  end

  def unsubscribe_error(conn, error) do
    Logger.error("Tried to unsubscribe from the old room and failed - #{inspect(error)}")

    conn
  end

  def subscribe_error(conn, error) do
    Logger.error("Tried to subscribe to the new room and failed - #{inspect(error)}")

    conn
  end
end
