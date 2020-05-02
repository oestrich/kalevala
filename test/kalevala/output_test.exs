defmodule Kalevala.Output.TagsTest do
  use ExUnit.Case

  alias Kalevala.Output
  alias Kalevala.Output.Tables
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

  describe "tables" do
    test "parses table tags" do
      iodata = [~s(Table {table}   {row}\n{cell}Hello, world{/cell}{/row}{/table} Table\n)]

      actual_text =
        iodata
        |> Output.process(Tags)
        |> Output.process(Tables)
        |> Enum.join("")

      expected_text = """
      Table 
      +--------------+
      | Hello, world |
      +--------------+
       Table
      """

      assert actual_text == expected_text
    end

    test "complicated table" do
      iodata = """
      {table}
        {row}
          {cell}Player Name{/cell}
        {/row}
        {row}
          {cell}HP{/cell}
          {cell}{color foreground="red"}50/50{/color}{/cell}
        {/row}
        {row}
          {cell}Hello{/cell}
          {cell}Hiya{/cell}
          {cell}Howdy{/cell}
        {/row}
      {/table}
      """

      actual_text =
        iodata
        |> Output.process(Tags)
        |> Output.process(Tables)
        |> Output.process(TagColors)
        |> Enum.join("")

      expected_text = """
      +----------------------+
      |     Player Name      |
      +----------------------+
      |   HP    |   \e[31m50/50\e[0m    |
      +----------------------+
      | Hello | Hiya | Howdy |
      +----------------------+
      """

      assert actual_text == expected_text
    end

    test "extra text outside of a cell skips processing" do
      iodata = [~s(Table {table}{row}Hello, {cell}world{/cell}{/row}{/table} Table)]

      actual_text =
        iodata
        |> Output.process(Tags)
        |> Output.process(Tables)

      assert actual_text == [
               "Table ",
               {:open, "table", %{}},
               "",
               {:open, "row", %{}},
               "Hello, ",
               {:open, "cell", %{}},
               "world",
               {:close, "cell"},
               "",
               {:close, "row"},
               "",
               {:close, "table"},
               " Table"
             ]
    end
  end
end
