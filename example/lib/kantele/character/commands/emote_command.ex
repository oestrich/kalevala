defmodule Kantele.Character.EmoteCommand do
  use Kalevala.Character.Command, dynamic: true

  alias Kantele.Character.Emotes
  alias Kantele.Character.EmoteAction
  alias Kantele.Character.EmoteView

  @impl true
  def parse(text, _opts) do
    case Emotes.get(text) do
      {:ok, command} ->
        {:dynamic, :broadcast, %{"text" => command.text}}

      {:error, :not_found} ->
        :skip
    end
  end

  def broadcast(conn, params) do
    channel_name = "rooms:#{conn.character.room_id}"

    conn
    |> assign(:text, params["text"])
    |> render(EmoteView, "echo")
    |> EmoteAction.run(%{channel_name: channel_name, text: params["text"]})
    |> assign(:prompt, false)
  end

  def list(conn, _params) do
    emotes = Enum.sort(Emotes.keys())

    render(conn, EmoteView, "list", %{emotes: emotes})
  end
end
