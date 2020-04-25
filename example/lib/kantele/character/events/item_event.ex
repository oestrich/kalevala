defmodule Kantele.Character.ItemEvent do
  use Kalevala.Character.Event

  require Logger

  alias Kantele.Character.CommandView
  alias Kantele.Character.ItemView
  alias Kantele.World.Items

  def commit(conn, %{data: event}) do
    inventory = [event.item_instance | conn.character.inventory]

    item = Items.get!(event.item_instance.item_id)

    conn
    |> put_character(%{conn.character | inventory: inventory})
    |> render(ItemView, "success", %{item: item})
    |> render(CommandView, "prompt")
  end

  def abort(conn, %{data: event}) do
    conn
    |> render(ItemView, "fail", event)
    |> render(CommandView, "prompt")
  end
end
