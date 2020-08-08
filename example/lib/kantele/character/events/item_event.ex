defmodule Kantele.Character.ItemEvent do
  use Kalevala.Character.Event

  require Logger

  alias Kantele.Character.CommandView
  alias Kantele.Character.ItemView
  alias Kantele.World.Items

  def drop_abort(conn, %{data: event}) do
    conn
    |> render(ItemView, "drop-abort", event)
    |> render(CommandView, "prompt")
  end

  def drop_commit(conn, %{data: event}) do
    inventory =
      Enum.reject(conn.character.inventory, fn item_instance ->
        event.item_instance.id == item_instance.id
      end)

    item = Items.get!(event.item_instance.item_id)
    item_instance = %{event.item_instance | item: item}

    conn
    |> put_character(%{conn.character | inventory: inventory})
    |> render(ItemView, "drop-commit", %{item: item, item_instance: item_instance})
    |> render(CommandView, "prompt")
  end

  def pickup_abort(conn, %{data: event}) do
    conn
    |> render(ItemView, "pickup-abort", event)
    |> render(CommandView, "prompt")
  end

  def pickup_commit(conn, %{data: event}) do
    inventory = [event.item_instance | conn.character.inventory]

    item = Items.get!(event.item_instance.item_id)
    item_instance = %{event.item_instance | item: item}

    conn
    |> put_character(%{conn.character | inventory: inventory})
    |> render(ItemView, "pickup-commit", %{item: item, item_instance: item_instance})
    |> render(CommandView, "prompt")
  end
end
