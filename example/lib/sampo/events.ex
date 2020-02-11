defmodule Sampo.Events do
  @moduledoc false

  use Kalevala.Event.Router

  scope(Sampo) do
    module(CombatEvent) do
      event("combat/start", :start)
      event("combat/stop", :stop)
      event("combat/tick", :tick)
    end

    module(MoveEvent) do
      event("movement/commit", :commit)
      event("movement/fail", :fail)
    end

    module(SayEvent) do
      event("room/say", :echo)
    end
  end
end
