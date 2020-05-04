defmodule Kantele.Character.EmoteAction do
  @moduledoc """
  Action to emote in a channel (e.g. a room)
  """

  use Kalevala.Character.Action

  @impl true
  def run(conn, data) do
    publish_emote(conn, data.channel_name, data.text, [], &publish_error/2)
  end

  def publish_error(conn, _error), do: conn
end
