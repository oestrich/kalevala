defmodule Kantele.Character.GetCommand do
  use Kalevala.Character.Command

  def run(conn, %{"item_name" => item_name}) do
    conn
    |> request_item_pickup(item_name)
    |> assign(:prompt, false)
  end
end
