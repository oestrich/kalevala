defmodule Kantele.Character.ItemView do
  use Kalevala.Character.View

  def render("name", %{item_instance: item_instance}) do
    [
      ~i({item-instance id="#{item_instance.id}"}),
      render("name", %{item: item_instance.item}),
      ~i({/item-instance})
    ]
  end

  def render("name", %{item: item}) do
    ~i({item id="#{item.id}"}#{item.name}{/item})
  end

  def render("drop-abort", %{reason: :no_item, item_name: item_name}) do
    render("unknown", %{item_name: item_name})
  end

  def render("drop-commit", %{item: item}) do
    ~i(You dropped #{render("name", %{item: item})}.\n)
  end

  def render("pickup-abort", %{reason: :no_item, item_name: item_name}) do
    render("unknown", %{item_name: item_name})
  end

  def render("pickup-commit", %{item: item}) do
    ~i(You picked up #{render("name", %{item: item})}.\n)
  end

  def render("unknown", %{item_name: item_name}) do
    ~i(There is no item {color foreground="white"}"#{item_name}"{/color}.\n)
  end
end
