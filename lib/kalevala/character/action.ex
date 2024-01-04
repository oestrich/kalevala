defmodule Kalevala.Character.Action do
  @moduledoc """
  Actions are small character functionality bundled together

  For instance, you might have an action to speak into a room, or
  flee in a random direction.
  """

  @callback run(Conn.t(), map()) :: Conn.t()

  defstruct [:request_id, :type, delay: 0, params: %{}]

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Character.Conn

      @behaviour Kalevala.Character.Action
    end
  end
end
