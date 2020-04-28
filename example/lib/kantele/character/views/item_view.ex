defmodule Kantele.Character.ItemView do
  use Kalevala.Character.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("name", %{item: item}) do
    ~i(#{white()}#{item.name}#{reset()})
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
    ~i(There is no item #{white()}"#{item_name}"#{reset()}.\n)
  end
end
