defmodule Kalevala.Character.Command do
  @moduledoc """
  Commands handle player actions
  """

  @doc """
  Sets up a module to be a command

  To create a dynamic command, which parses player text to
  determine if it matches:

      defmodule MyCommand do
        use Kalevala.Character.Command, dynamic: true
      end
  """
  defmacro __using__(opts) do
    dynamic = Keyword.get(opts, :dynamic, false)

    quote do
      import Kalevala.Character.Conn

      if unquote(dynamic) do
        @behaviour Kalevala.Character.Command.DynamicCommand
      end
    end
  end
end
