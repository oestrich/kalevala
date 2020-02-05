defmodule KalevalaTest do
  use ExUnit.Case
  doctest Kalevala

  test "greets the world" do
    assert Kalevala.hello() == :world
  end
end
