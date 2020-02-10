defmodule Sampo.WhoCommand do
  use Kalevala.Command

  def run(conn, _params) do
    conn
    |> event("characters/list", %{})
    |> assign(:prompt, false)
  end
end
