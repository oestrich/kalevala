defmodule Kantele.Events do
  @moduledoc false

  use Kalevala.Event.Router

  scope(Kantele) do
    module(CombatEvent) do
      event("combat/start", :start)
      event("combat/stop", :stop)
      event("combat/tick", :tick)
    end

    module(MoveEvent) do
      event(Kalevala.Event.Movement.Commit, :commit)
      event(Kalevala.Event.Movement.Abort, :abort)
    end

    module(SayEvent) do
      event(Kalevala.Event.Message, :echo)
    end
  end
end
