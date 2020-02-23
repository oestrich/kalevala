defmodule Kantele.Character.Events do
  @moduledoc false

  use Kalevala.Event.Router

  alias Kalevala.Event.Message
  alias Kalevala.Event.Movement
  alias Kantele.Character.ChannelEvent
  alias Kantele.Character.SayEvent

  scope(Kantele.Character) do
    module(CombatEvent) do
      event("combat/start", :start)
      event("combat/stop", :stop)
      event("combat/tick", :tick)
    end

    module(MoveEvent) do
      event(Movement.Commit, :commit)
      event(Movement.Abort, :abort)
    end

    module(SayEvent) do
      event(Message, :echo, interested?: &SayEvent.interested?/1)
    end

    module(ChannelEvent) do
      event(Message, :echo, interested?: &ChannelEvent.interested?/1)
    end
  end
end
