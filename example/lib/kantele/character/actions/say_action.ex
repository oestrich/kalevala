defmodule Kantele.Character.SayAction do
  @moduledoc """
  Action to speak in a channel (e.g. a room)
  """

  use Kalevala.Character.Action

  alias Kantele.Character.SayView

  @impl true
  def run(conn, params) do
    conn
    |> assign(:text, params["text"])
    |> render(SayView, "echo")
    |> publish_message(params["channel_name"], params["text"], [], &publish_error/2)
  end

  def publish_error(conn, _error), do: conn
end
