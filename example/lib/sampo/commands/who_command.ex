defmodule Sampo.WhoCommand do
  use Kalevala.Command

  alias Sampo.WhoView

  def run(conn, _params) do
    conn
    |> assign(:characters, Sampo.Presence.characters())
    |> render(WhoView, "list")
  end
end
