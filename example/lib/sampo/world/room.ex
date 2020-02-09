defmodule Sampo.World.Room do
  @moduledoc """
  Callbacks for a Kalevala room
  """

  @behaviour Kalevala.World.Room

  alias Kalevala.Event
  alias Sampo.CommandView
  alias Sampo.LookView

  @impl true
  def init(room), do: room

  @impl true
  def event(room, event = %Event{topic: "combat/start"}) do
    send(event.from_pid, event)
    room
  end

  def event(room, event = %Event{topic: "combat/stop"}) do
    send(event.from_pid, event)
    room
  end

  def event(room, event = %Event{topic: "combat/tick"}) do
    send(event.from_pid, event)
    room
  end

  def event(room, event = %Event{topic: "room/look"}) do
    look_line = %Kalevala.Conn.Lines{
      data: LookView.render("look", %{room: room}),
      newline: false
    }

    prompt_line = %Kalevala.Conn.Lines{
      data: CommandView.render("prompt", %{}),
      newline: true
    }

    send(event.from_pid, %Event.Display{lines: [look_line, prompt_line]})

    room
  end
end
