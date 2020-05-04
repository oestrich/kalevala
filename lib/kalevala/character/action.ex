defmodule Kalevala.Character.Action do
  @moduledoc """
  Actions are small character functionality bundled together

  For instance, you might have an action to speak into a room, or
  flee in a random direction.
  """

  @callback run(Conn.t(), map()) :: :ok

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Character.Conn

      @behaviour Kalevala.Character.Action
    end
  end
end
