defmodule Kantele.Character.SayCommand do
  use Kalevala.Character.Command

  alias Kantele.Character.SayView

  def run(conn, params) do
    channel_name = "rooms:#{conn.character.room_id}"

    conn
    |> assign(:text, params["text"])
    |> render(SayView, "echo")
    |> publish_message(channel_name, params["text"], [], &publish_error/2)
    |> assign(:prompt, false)
  end

  def publish_error(conn, _error), do: conn
end
