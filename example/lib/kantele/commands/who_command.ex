defmodule Kantele.WhoCommand do
  use Kalevala.Command

  alias Kantele.WhoView

  def run(conn, _params) do
    conn
    |> assign(:characters, Kantele.Presence.characters())
    |> render(WhoView, "list")
  end
end
