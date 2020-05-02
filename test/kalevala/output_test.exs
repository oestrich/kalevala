defmodule Kalevala.Output.TagsTest do
  use ExUnit.Case

  alias Kalevala.Output
  alias Kalevala.Output.Tags
  alias Kalevala.Output.TagColors

  describe "callbacks to change output" do
    test "no modification" do
      text =
        ["hello ", "world"]
        |> Output.process(Tags)
        |> Output.process(TagColors)

      assert text == ["hello world"]
    end

    test "simple coloration" do
      iodata = [~s(hello, {color foreground="white" background="black"}world{/color})]

      text =
        iodata
        |> Output.process(Tags)
        |> Output.process(TagColors)

      assert text == ["hello, ", "\e[37m", "\e[40m", "world", "\e[0m", ""]
    end

    test "allows for coloration" do
      iodata = [~s(hello, {color ), ~s(foreground="white"} ), ["world"], [["{/color}"]], []]

      text =
        iodata
        |> Output.process(Tags)
        |> Output.process(TagColors)

      assert text == ["hello, ", "\e[37m", " world", "\e[0m", ""]
    end

    test "stacking colors" do
      iodata = [
        ~s(hello, {color foreground="white"} {color foreground="blue"}world{/color}{/color})
      ]

      text =
        iodata
        |> Output.process(Tags)
        |> Output.process(TagColors)

      assert text == ["hello, ", "\e[37m", " ", "\e[34m", "world", "\e[37m", "", "\e[0m", ""]
    end

    test "allows special characters to be included but ignored" do
      iodata = [~s(hello, \\{color foreground="white"\\}world\\{/color\\})]

      text =
        iodata
        |> Output.process(Tags)
        |> Output.process(TagColors)

      assert text == [~s(hello, {color foreground="white"}world{/color})]
    end
  end
end
