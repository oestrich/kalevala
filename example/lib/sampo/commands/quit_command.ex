defmodule Sampo.QuitCommand do
  use Kalevala.Command

  alias Sampo.QuitView

  def run(conn, _params) do
    conn
    |> render(QuitView, "goodbye")
    |> halt()
  end
end
