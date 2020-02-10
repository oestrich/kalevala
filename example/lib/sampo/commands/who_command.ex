defmodule Sampo.WhoCommand do
  use Kalevala.Command

  alias Sampo.WhoView

  def run(conn, _params) do
    characters = Sampo.Presence.characters()
    render(conn, WhoView, "list", %{characters: characters})
  end
end
