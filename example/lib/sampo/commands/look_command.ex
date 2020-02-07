defmodule Sampo.LookCommand do
  use Kalevala.Command

  alias Sampo.LookView

  def run(conn, _params) do
    render(conn, LookView, "look", %{})
  end
end
