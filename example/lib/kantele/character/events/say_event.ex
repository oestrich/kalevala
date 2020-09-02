defmodule Kantele.Character.SayEvent do
  use Kalevala.Character.Event

  alias Kantele.Character.CommandView
  alias Kantele.Character.SayView

  def interested?(event) do
    event.data.type == "speech" && match?("rooms:" <> _, event.data.channel_name)
  end

  def echo(conn, event) do
    conn
    |> assign(:character, event.data.character)
    |> assign(:id, event.data.id)
    |> assign(:text, event.data.text)
    |> render(SayView, say_view(event))
    |> prompt(CommandView, "prompt", %{})
  end

  defp say_view(event) do
    case event.from_pid == self() do
      true ->
        "echo"

      false ->
        "listen"
    end
  end

  def publish_error(conn, _error), do: conn
end
