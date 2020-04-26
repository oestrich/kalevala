defmodule Kantele.Character.EmoteCommand do
  use Kalevala.Character.Command

  alias Kantele.Character.EmoteView

  def run(conn, params) do
    channel_name = "rooms:#{conn.character.room_id}"

    conn
    |> assign(:text, params["text"])
    |> render(EmoteView, "echo")
    |> publish_emote(channel_name, params["text"], [], &publish_error/2)
    |> assign(:prompt, false)
  end

  def publish_error(conn, _error), do: conn
end
