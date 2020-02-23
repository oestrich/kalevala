defmodule Kalevala.Character.Command do
  @moduledoc """
  Commands handle player actions
  """

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Character.Conn
    end
  end
end
