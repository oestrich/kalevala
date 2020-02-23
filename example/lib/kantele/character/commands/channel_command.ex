defmodule Kantele.Character.ChannelCommand do
  use Kalevala.Character.Command

  alias Kantele.Character.ChannelView

  def general(conn, params) do
    conn
    |> assign(:channel_name, "general")
    |> assign(:text, params["text"])
    |> render(ChannelView, "echo")
    |> publish_message("general", params["text"], [], &publish_error/2)
    |> assign(:prompt, false)
  end

  def publish_error(conn, _error), do: conn
end
