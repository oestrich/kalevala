defmodule Sampo.Commands do
  @moduledoc false

  use Kalevala.Command.Router

  scope(Sampo) do
    module(CombatCommand) do
      command("combat start", :start)
      command("combat stop", :stop)
      command("combat tick", :tick)
    end

    module(LookCommand) do
      command("look", :run)
    end

    module(QuitCommand) do
      command("quit", :run)
      command(<<4>>, :run, display: false)
    end

    module(SayCommand) do
      command("say :message", :run)
    end

    module(WhoCommand) do
      command("who", :run)
    end
  end
end
