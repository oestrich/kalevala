defmodule Kalevala.Character.Command do
  @moduledoc """
  Commands handle player actions
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
