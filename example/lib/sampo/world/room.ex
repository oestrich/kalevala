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

  @impl true
  def movement_request(room, event) do
    room.exits
    |> Enum.find(fn exit ->
      exit.exit_name == event.exit_name
    end)
    |> maybe_vote(room, event)
  end

  defp maybe_vote(nil, room, event) do
    %Kalevala.Event.Movement.Voting{
      state: :abort,
      character: event.character,
      from: room.id,
      exit_name: event.exit_name,
      reason: :no_exit
    }
  end

  defp maybe_vote(room_exit, room, event) do
    %Kalevala.Event.Movement.Voting{
      state: :request,
      character: event.character,
      from: room.id,
      to: room_exit.end_room_id,
      exit_name: room_exit.exit_name
    }
  end

  @impl true
  def confirm_movement(context, event), do: {context, event}
end

defmodule Sampo.World.Room.Events do
  @moduledoc false

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

    module(MoveEvent) do
      event("movement/start", :start)
    end

    module(NotifyEvent) do
      event("room/say", :call)
    end
  end
end

defmodule Sampo.World.Room.ForwardEvent do
  import Kalevala.World.Room.Context

  def call(context, event) do
    event(context, event.from_pid, self(), event.topic, %{})
  end
end

defmodule Sampo.World.Room.LookEvent do
  import Kalevala.World.Room.Context

  alias Sampo.LookView

  def call(context, event) do
    context
    |> assign(:room, context.data)
    |> assign(:characters, context.characters)
    |> render(event.from_pid, LookView, "look", %{})
  end
end

defmodule Sampo.World.Room.MoveEvent do
  import Kalevala.World.Room.Context

  def start(context, event) do
    room_exit =
      Enum.find(context.data.exits, fn exit ->
        exit.exit_name == event.data.exit_name
      end)

    case room_exit != nil do
      true ->
        event(context, event.from_pid, self(), "movement/commit", %{
          room_id: room_exit.end_room_id
        })

      false ->
        event(context, event.from_pid, self(), "movement/fail", %{
          reason: :no_exit,
          exit_name: event.data.exit_name
        })
    end
  end
end

defmodule Sampo.World.Room.NotifyEvent do
  import Kalevala.World.Room.Context

  def call(context, event) do
    Enum.reduce(context.characters, context, fn character, context ->
      event(context, character.pid, event.from_pid, event.topic, event.data)
    end)
  end
end
