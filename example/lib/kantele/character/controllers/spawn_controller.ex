defmodule Kantele.Character.SpawnController do
  use Kalevala.Character.Controller

  alias Kalevala.Character.Brain.Node
  alias Kantele.Character.MoveEvent
  alias Kantele.Character.SpawnView

  @impl true
  def init(conn) do
    character = conn.character

    conn
    |> move(:to, character.room_id, SpawnView, "spawn", %{})
    |> subscribe("rooms:#{character.room_id}", [], &MoveEvent.subscribe_error/2)
    |> event("room/look", %{})
  end

  @impl true
  def event(conn, event) do
    Node.run(conn.character.meta.brain, conn, event)
  end

  @impl true
  def recv(conn, _text), do: conn

  @impl true
  def option(conn, _text), do: conn

  @impl true
  def display(conn, _text), do: conn
end
