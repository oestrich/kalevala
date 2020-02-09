defmodule Kalevala.Event do
  @moduledoc """
  An internal event
  """

  @type t() :: %__MODULE__{}

  @type topic() :: String.t()

  defstruct [:from_pid, :topic, :data]

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Controller,
        only: [event: 3, get_session: 2, halt: 1, prompt: 4, put_session: 3, render: 4]
    end
  end
end
