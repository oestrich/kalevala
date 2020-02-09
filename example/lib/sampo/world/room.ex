defmodule Sampo.World.Room do
  @moduledoc """
  Callbacks for a Kalevala room
  """

  use Kalevala.World.Room

  alias Kalevala.Event
  alias Sampo.CommandView
  alias Sampo.LookView

  @impl true
  def init(room), do: room

  @impl true
  def event(context, event = %Event{topic: "combat/start"}) do
    event(context, event.from_pid, event.topic, %{})
  end

  def event(context, event = %Event{topic: "combat/stop"}) do
    event(context, event.from_pid, event.topic, %{})
  end

  def event(context, event = %Event{topic: "combat/tick"}) do
    event(context, event.from_pid, event.topic, %{})
  end

  def event(context, event = %Event{topic: "room/look"}) do
    context
    |> assign(:room, context.data)
    |> render(event.from_pid, LookView, "look", %{})
    |> prompt(event.from_pid, CommandView, "prompt", %{})
  end
end
