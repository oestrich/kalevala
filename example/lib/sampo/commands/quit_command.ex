defmodule Sampo.QuitCommand do
  use Kalevala.Command

  alias Sampo.QuitView

  def run(conn, params) do
    conn
    |> render(QuitView, "goodbye", params)
    |> halt()
  end
end
