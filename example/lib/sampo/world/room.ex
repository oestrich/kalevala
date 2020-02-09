defmodule Sampo.World.Room do
  @moduledoc """
  Callbacks for a Kalevala room
  """

  use Kalevala.World.Room

  alias Sampo.World.Room.Events

  @impl true
  def init(room), do: room

  @impl true
  def event(context, event) do
    Events.call(context, event)
  end
end

defmodule Sampo.World.Room.Events do
  use Kalevala.Event.Router

  scope(Sampo.World.Room) do
    module(ForwardEvent) do
      event("combat/start", :call)
      event("combat/stop", :call)
      event("combat/tick", :call)
    end

    module(LookEvent) do
      event("room/look", :call)
    end
  end
end

defmodule Sampo.World.Room.ForwardEvent do
  import Kalevala.World.Room.Context

  def call(context, event) do
    event(context, event.from_pid, event.topic, %{})
  end
end

defmodule Sampo.World.Room.LookEvent do
  import Kalevala.World.Room.Context

  alias Sampo.CommandView
  alias Sampo.LookView

  def call(context, event) do
    context
    |> assign(:room, context.data)
    |> render(event.from_pid, LookView, "look", %{})
    |> prompt(event.from_pid, CommandView, "prompt", %{})
  end
end
