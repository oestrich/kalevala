defmodule Example.LookCommand do
  use Kalevala.Command

  alias Example.LookView

  def run(conn, _params) do
    render(conn, LookView, "look", %{})
  end
end
