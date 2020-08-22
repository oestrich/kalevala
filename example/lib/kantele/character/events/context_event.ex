defmodule Kantele.Character.ContextEvent do
  use Kalevala.Character.Event

  alias Kalevala.World.Item
  alias Kantele.Character.ContextView
  alias Kantele.World.Items

  def lookup(conn, %{data: %{"context" => "room", "type" => "item", "id" => id}}) do
    event(conn, "context/lookup", %{type: :item, id: id})
  end

  def lookup(conn, %{data: %{"context" => "inventory", "type" => "item", "id" => item_id}}) do
    item_instance =
      Enum.find(conn.character.inventory, fn item_instance ->
        item_instance.item_id == item_id
      end)

    case item_instance != nil do
      true ->
        item = Items.get!(item_id)

        actions = Item.context_actions(item, %{location: "inventory/self"})

        conn
        |> assign(:context, "inventory")
        |> assign(:item, item)
        |> assign(:actions, actions)
        |> render(ContextView, "item")

      false ->
        handle_unknown(conn, "inventory", "item", item_id)
    end
  end

  def lookup(conn, %{data: %{"context" => context, "type" => type, "id" => id}}) do
    handle_unknown(conn, context, type, id)
  end

  defp handle_unknown(conn, context, type, id) do
    conn
    |> assign(:context, context)
    |> assign(:type, type)
    |> assign(:id, id)
    |> render(ContextView, "unknown")
  end
end
