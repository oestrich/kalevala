defmodule Kantele.Character.Commands do
  @moduledoc false

  use Kalevala.Character.Command.Router

  scope(Kantele.Character) do
    module(CombatCommand) do
      command("combat start", :start)
      command("combat stop", :stop)
      command("combat tick", :tick)
    end

    module(GetCommand) do
      command("get :item_name", :run)
    end

    module(LookCommand) do
      command("look", :run)
    end

    module(InventoryCommand) do
      command("i", :run)
      command("inv", :run)
      command("inventory", :run)
    end

    module(MoveCommand) do
      command("north", :north)
      command("south", :south)
      command("east", :east)
      command("west", :west)
    end

    module(QuitCommand) do
      command("quit", :run)
      command(<<4>>, :run, display: false)
    end

    module(SayCommand) do
      command("say :text", :run)
    end

    module(ChannelCommand) do
      command("general :text", :general)
    end

    module(WhoCommand) do
      command("who", :run)
    end
  end
end
