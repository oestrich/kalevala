defmodule Kantele.Character.SayAction do
  @moduledoc """
  Action to speak in a channel (e.g. a room)
  """

  use Kalevala.Character.Action

  @impl true
  def run(conn, data) do
    publish_message(conn, data.channel_name, data.text, [], &publish_error/2)
  end

  def publish_error(conn, _error), do: conn
end
