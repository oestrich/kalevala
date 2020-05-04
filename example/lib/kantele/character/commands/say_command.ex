defmodule Kantele.Character.SayCommand do
  use Kalevala.Character.Command

  alias Kantele.Character.SayAction
  alias Kantele.Character.SayView

  def run(conn, params) do
    channel_name = "rooms:#{conn.character.room_id}"

    conn
    |> assign(:text, params["text"])
    |> render(SayView, "echo")
    |> SayAction.run(%{channel_name: channel_name, text: params["text"]})
    |> assign(:prompt, false)
  end
end
