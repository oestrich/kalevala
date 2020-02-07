defmodule Kalevala.Command do
  @moduledoc """
  Commands handle player actions
  """

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Controller, only: [halt: 1, prompt: 4, render: 4]
    end
  end
end
