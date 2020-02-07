defmodule Example.QuitCommand do
  use Kalevala.Command

  alias Example.QuitView

  def run(conn, params) do
    conn
    |> render(QuitView, "goodbye", params)
    |> halt()
  end
end
