defmodule Kantele.ChannelEvent do
  use Kalevala.Event

  alias Kantele.ChannelView
  alias Kantele.CommandView

  def interested?(event) do
    match?("general", event.data.channel_name)
  end

  def echo(conn, event) do
    case event.from_pid == self() do
      true ->
        prompt(conn, CommandView, "prompt", %{})

      false ->
        conn
        |> assign(:channel_name, "general")
        |> assign(:character_name, event.data.character.name)
        |> assign(:text, event.data.text)
        |> render(ChannelView, "listen")
        |> prompt(CommandView, "prompt", %{})
    end
  end

  def subscribe_error(conn, _error), do: conn
end
