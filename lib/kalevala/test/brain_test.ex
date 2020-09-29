defmodule Kalevala.BrainTest do
  @moduledoc """
  Test Helpers for testing a Brain struct
  """

  @doc """
  Assert a value in the brain's state
  """
  defmacro assert_brain_value(brain, key, value) do
    quote do
      assert Kalevala.Brain.get(unquote(brain), unquote(key)) == unquote(value)
    end
  end
end
