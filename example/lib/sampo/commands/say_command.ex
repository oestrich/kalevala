defmodule Sampo.SayCommand do
  use Kalevala.Command

  alias Sampo.SayView

  def run(conn, params) do
    params = %{
      "character_name" => character(conn).name,
      "message" => params["message"]
    }

    conn
    |> render(SayView, "echo", params)
    |> event("room/say", params)
    |> assign(:prompt, false)
  end
end
