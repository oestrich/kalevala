defmodule Kantele.Character.EmoteCommand do
  use Kalevala.Character.Command, dynamic: true

  alias Kantele.Character.Emotes
  alias Kantele.Character.EmoteView

  @impl true
  def parse(text, _opts) do
    case Emotes.get(text) do
      {:ok, command} ->
        {:dynamic, :run, %{"text" => command.text}}

      {:error, :not_found} ->
        :skip
    end
  end

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
