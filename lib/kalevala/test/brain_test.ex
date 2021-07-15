defmodule Kalevala.BrainTest do
  @moduledoc """
  Test Helpers for testing a Brain struct
  """

  alias Kalevala.Character.Conn

  @doc """
  Assert a value in the brain's state
  """
  defmacro assert_brain_value(conn_or_brain, key, value) do
    quote do
      brain = Kalevala.BrainTest.brain(unquote(conn_or_brain))

      assert Kalevala.Brain.get(brain, unquote(key)) == unquote(value)
    end
  end

  @doc """
  Run the brain inside the `conn`
  """
  def run_brain(conn, event) do
    brain = Conn.character(conn).brain

    Kalevala.Brain.run(brain, conn, event)
  end

  def brain(conn = %Conn{}), do: Conn.character(conn).brain

  def brain(brain), do: brain
end
