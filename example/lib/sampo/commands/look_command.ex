defmodule Sampo.LookCommand do
  use Kalevala.Command

  def run(conn, _params) do
    conn
    |> event("room/look", %{})
    |> assign(:prompt, false)
  end
end
