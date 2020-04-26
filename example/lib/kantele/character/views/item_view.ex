defmodule Kantele.Character.ItemView do
  use Kalevala.Character.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("drop-abort", %{reason: :no_item, item_name: item_name}) do
    ~i(There is no item #{white()}"#{item_name}"#{reset()}.\n)
  end

  def render("drop-commit", %{item: item}) do
    ~i(You dropped #{white()}#{item.name}#{reset()}.\n)
  end

  def render("pickup-abort", %{reason: :no_item, item_name: item_name}) do
    ~i(There is no item #{white()}"#{item_name}"#{reset()}.\n)
  end

  def render("pickup-commit", %{item: item}) do
    ~i(You picked up #{white()}#{item.name}#{reset()}.\n)
  end

  def render("unknown", %{item_name: item_name}) do
    ~i(There is no item #{white()}"#{item_name}"#{reset()}.\n)
  end
end
