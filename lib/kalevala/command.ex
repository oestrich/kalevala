defmodule Kalevala.Command do
  @moduledoc """
  Commands handle player actions
  """

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Conn
    end
  end
end
