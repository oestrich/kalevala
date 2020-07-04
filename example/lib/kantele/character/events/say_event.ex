defmodule Kantele.Character.SayEvent do
  use Kalevala.Character.Event

  alias Kantele.Character.CommandView
  alias Kantele.Character.SayView

  def interested?(event) do
    !event.data.emote && match?("rooms:" <> _, event.data.channel_name)
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

  def echo_chamber(conn, event) do
    case event.from_pid == self() do
      true ->
        conn

      false ->
        publish_message(conn, event.data.channel_name, event.data.text, [], &publish_error/2)
    end
  end

  def publish_error(conn, _error), do: conn
end
