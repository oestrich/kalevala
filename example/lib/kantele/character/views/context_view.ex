defmodule Kantele.Character.ContextView do
  use Kalevala.Character.View

  alias Kalevala.Character.Conn.Event

  def render("item", %{context: context, item: item, actions: actions}) do
    %Event{
      topic: "Context.Actions",
      data: %{
        context: context,
        type: "item",
        id: item.id,
        actions: actions
      }
    }
  end

  def render("unknown", %{context: context, id: id}) do
    %Event{
      topic: "context/items",
      data: %{
        error: "Unknown context",
        data: %{
          context: context,
          id: id
        }
      }
    }
  end
end
