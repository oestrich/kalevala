defmodule Sampo.World.Room do
  @moduledoc """
  Callbacks for a Kalevala room
  """

  @behaviour Kalevala.World.Room

  @impl true
  def init(room), do: room

  @impl true
  def event(room, event = %Kalevala.Event{topic: "combat/start"}) do
    send(event.from_pid, event)
    room
  end

  def event(room, event = %Kalevala.Event{topic: "combat/stop"}) do
    send(event.from_pid, event)
    room
  end

  def event(room, event = %Kalevala.Event{topic: "combat/tick"}) do
    send(event.from_pid, event)
    room
  end
end
