defmodule Sampo.SayCommand do
  use Kalevala.Command

  alias Sampo.SayView

  def run(conn, params) do
    render(conn, SayView, "echo", params)
  end
end
