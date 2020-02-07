defmodule Example.Events do
  use Kalevala.Event.Router

  scope(Example) do
    module(CombatEvent) do
      event("combat/start", :start)
      event("combat/stop", :stop)
      event("combat/tick", :tick)
    end
  end
end
