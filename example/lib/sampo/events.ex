defmodule Sampo.Events do
  @moduledoc false

  use Kalevala.Event.Router

  scope(Sampo) do
    module(CombatEvent) do
      event("combat/start", :start)
      event("combat/stop", :stop)
      event("combat/tick", :tick)
    end
  end
end
