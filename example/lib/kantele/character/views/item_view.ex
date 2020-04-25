defmodule Kantele.Character.ItemView do
  use Kalevala.Character.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("success", %{item: item}) do
    ~i(You picked up #{white()}#{item.name}#{reset()}.\n)
  end

  def render("fail", %{reason: :no_item, item_name: item_name}) do
    ~i(There is no item #{white()}"#{item_name}"#{reset()}.\n)
  end
end
