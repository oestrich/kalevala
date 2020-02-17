defmodule Kantele.QuitCommand do
  use Kalevala.Command

  alias Kantele.QuitView

  def run(conn, _params) do
    conn
    |> render(QuitView, "goodbye")
    |> halt()
  end
end
