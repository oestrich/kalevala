defmodule Example.Commands do
  use Kalevala.Command.Router

  scope(Example) do
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
  end
end
