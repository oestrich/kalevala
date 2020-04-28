defmodule Kalevala.Character.ViewTest do
  use ExUnit.Case

  import Kalevala.Character.View.Macro

  alias Kalevala.Character.View

  describe "joining lines" do
    test "simple case" do
      assert View.join(["one", "two"], "\n") == ["one", "\n", "two"]
    end

    test "io data" do
      io = ["one", ["two", "three"], ["four"]]

      assert View.join(io, "\n") == ["one", "\n", ["two", "three"], "\n", ["four"]]
    end
  end

  describe "trimming lines blank" do
    test "nothing to trim" do
      assert View.trim_lines(["one", "\n", "two"]) == ["one", "\n", "two"]
    end

    test "a blank extra line with a string" do
      assert View.trim_lines(["one", "\n", "", "\n", "two"]) == ["one", "\n", "two"]
    end

    test "a blank extra line with a nil" do
      assert View.trim_lines(["one", "\n", nil, "\n", "two"]) == ["one", "\n", "two"]
    end
  end

  describe "eex sigil" do
    test "parses down to IO data" do
      string = ~E"""
      Hello
      <%= "world" %>
      """

      assert string == ["Hello\n", "world", "\n"]
    end

    test "handles variables" do
      name = "world"

      string = ~E"""
      Hello
      <%= name %>
      """

      assert string == ["Hello\n", "world", "\n"]
    end
  end

  describe "io data sigil" do
    test "looks like a string but is io data" do
      string = ~i(hello, #{"world"})

      assert string == ["hello, ", "world"]
    end
  end
end
