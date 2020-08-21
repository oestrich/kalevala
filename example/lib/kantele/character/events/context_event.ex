defmodule Kantele.Character.ContextEvent do
  use Kalevala.Character.Event

  alias Kantele.Character.ContextView

  def lookup(conn, %{data: %{"context" => "room", "type" => "item", "id" => id}}) do
    event(conn, "context/lookup", %{type: :item, id: id})
  end

  def lookup(conn, %{data: %{"context" => context, "type" => type, "id" => id}}) do
    conn
    |> assign(:context, context)
    |> assign(:type, type)
    |> assign(:id, id)
    |> render(ContextView, "unknown")
  end
end
