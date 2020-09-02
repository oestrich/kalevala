defmodule Kalevala.Character.Command.RouterTest do
  use ExUnit.Case

  defmodule Router do
    use Kalevala.Character.Command.Router, scope: TestGame

    module(MoveCommand) do
      parse("north", :run)
    end

    module(SayCommand) do
      parse("say", :run, fn command ->
        command
        |> spaces()
        |> optional(
          symbol(">")
          |> word(:at)
          |> spaces()
        )
        |> text(:message)
      end)
    end

    module(TellCommand) do
      parse("tell", :run, fn command ->
        command
        |> spaces()
        |> word(:name)
        |> spaces()
        |> text(:message)
      end)
    end
  end

  describe "parsing commands" do
    test "a simple command" do
      {:ok, parsed_command} = Router.parse("north")

      assert parsed_command.module == TestGame.MoveCommand
      assert parsed_command.function == :run

      assert parsed_command.params == %{
               "command" => "north"
             }
    end

    test "a command with a single variable" do
      {:ok, parsed_command} = Router.parse("say hello there")

      assert parsed_command.module == TestGame.SayCommand
      assert parsed_command.function == :run

      assert parsed_command.params == %{
               "command" => "say",
               "message" => "hello there"
             }
    end

    test "a command with an optional word" do
      {:ok, parsed_command} = Router.parse("say >villager hello there")

      assert parsed_command.params == %{
               "command" => "say",
               "at" => "villager",
               "message" => "hello there"
             }

      {:ok, parsed_command} = Router.parse("say >\"town crier\" hello there")

      assert parsed_command.params == %{
               "command" => "say",
               "at" => "town crier",
               "message" => "hello there"
             }
    end

    test "a command with a word before text" do
      {:ok, parsed_command} = Router.parse("tell villager hello")

      assert parsed_command.module == TestGame.TellCommand
      assert parsed_command.function == :run

      assert parsed_command.params == %{
               "command" => "tell",
               "name" => "villager",
               "message" => "hello"
             }
    end

    test "a command with a quoted word before text" do
      {:ok, parsed_command} = Router.parse("tell \"town crier\" hello")

      assert parsed_command.module == TestGame.TellCommand
      assert parsed_command.function == :run

      assert parsed_command.params == %{
               "command" => "tell",
               "name" => "town crier",
               "message" => "hello"
             }
    end
  end
end
