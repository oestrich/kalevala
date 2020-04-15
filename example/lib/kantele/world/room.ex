defmodule Kantele.World.Room do
  @moduledoc """
  Callbacks for a Kalevala room
  """

  use Kalevala.World.Room

  require Logger

  alias Kantele.Communication
  alias Kantele.RoomChannel
  alias Kantele.World.Room.Events

  @impl true
  def init(room), do: room

  @impl true
  def initialized(room) do
    options = [room_id: room.id]

    with {:error, _reason} <- Communication.register("rooms:#{room.id}", RoomChannel, options) do
      Logger.warn("Failed to register the room's channel, did the room restart?")

      :ok
    end
  end

  @impl true
  def event(context, event) do
    Events.call(context, event)
  end

  @impl true
  def movement_request(_room, event, nil), do: {:abort, event, :no_exit}

  def movement_request(_room, event, room_exit), do: {:proceed, event, room_exit}

  @impl true
  def confirm_movement(context, event), do: {context, event}
end

defmodule Kantele.World.Room.Events do
  @moduledoc false

  use Kalevala.Event.Router

  scope(Kantele.World.Room) do
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

defmodule Kantele.World.Room.ForwardEvent do
  import Kalevala.World.Room.Context

  def call(context, event) do
    event(context, event.from_pid, self(), event.topic, %{})
  end
end

defmodule Kantele.World.Room.LookEvent do
  import Kalevala.World.Room.Context

  alias Kantele.Character.LookView

  def call(context, event) do
    context
    |> assign(:room, context.data)
    |> assign(:characters, context.characters)
    |> render(event.from_pid, LookView, "look", %{})
  end
end

defmodule Kantele.World.Room.NotifyEvent do
  import Kalevala.World.Room.Context

  def call(context, event) do
    Enum.reduce(context.characters, context, fn character, context ->
      event(context, character.pid, event.from_pid, event.topic, event.data)
    end)
  end
end
