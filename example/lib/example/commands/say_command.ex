defmodule Example.SayCommand do
  use Kalevala.Command

  alias Example.SayView

  def run(conn, params) do
    render(conn, SayView, "echo", params)
  end
end
