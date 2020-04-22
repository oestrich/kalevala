defmodule Kantele.Character.InventoryView do
  use Kalevala.Character.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("list", %{items: items}) do
    ~E"""
    You are holding:
    <%= render("_items", %{items: items}) %>
    """
  end

  def render("_items", %{items: items}) do
    items
    |> Enum.map(&render("_item", %{item: &1}))
    |> View.join("\n")
  end

  def render("_item", %{item: item}) do
    ~i(- #{white()}#{item.name}#{reset()})
  end
end
