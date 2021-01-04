defmodule Kalevala.Character.Event do
  @moduledoc """
  Process events in the context of a character
  """

  @type t() :: map()

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Character.Conn
    end
  end
end
