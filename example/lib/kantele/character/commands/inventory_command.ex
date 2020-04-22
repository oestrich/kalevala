defmodule Kantele.Character.InventoryCommand do
  use Kalevala.Character.Command

  alias Kantele.Character.InventoryView
  alias Kantele.World.Items

  def run(conn, _params) do
    items =
      Enum.map(conn.character.inventory, fn item_instance ->
        Items.get!(item_instance.item_id)
      end)

    conn
    |> assign(:items, items)
    |> render(InventoryView, "list")
  end
end
