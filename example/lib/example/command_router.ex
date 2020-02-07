defmodule Example.CommandRouter do
  use Kalevala.Command.Router

  scope(Example) do
    module(SayCommand) do
      command("say :message", :run)
    end

    module(QuitCommand) do
      command("quit", :run)
      command(<<4>>, :run, display: false)
    end
  end
end
