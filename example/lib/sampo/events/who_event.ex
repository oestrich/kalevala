defmodule Sampo.WhoEvent do
  use Kalevala.Event

  alias Sampo.CommandView
  alias Sampo.WhoView

  def run(conn, event) do
    conn
    |> render(WhoView, "list", event.data)
    |> prompt(CommandView, "prompt", %{})
  end
end
