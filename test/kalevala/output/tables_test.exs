defmodule Kalevala.Output.TablesTest do
  use ExUnit.Case

  alias Kalevala.Output
  alias Kalevala.Output.Tags
  alias Kalevala.Output.TagColors
  alias Kalevala.Output.Tables

  describe "parsing tables" do
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

  describe "table tag breathing room" do
    test "text before with no new line" do
      data =
        Tables.table_breathing_room([
          "Hello",
          %Tables.Tag{name: :table}
        ])

      assert data == ["Hello", "\n", %Tables.Tag{name: :table}]
    end

    test "text after with no new line" do
      data =
        Tables.table_breathing_room([
          %Tables.Tag{name: :table},
          "Hello"
        ])

      assert data == [%Tables.Tag{name: :table}, "\n", "Hello"]
    end

    test "text includes a separate newline before the tag" do
      data =
        Tables.table_breathing_room([
          "Hello",
          "\n",
          %Tables.Tag{name: :table}
        ])

      assert data == ["Hello", "\n", %Tables.Tag{name: :table}]
    end

    test "text includes a separate newline after the tag" do
      data =
        Tables.table_breathing_room([
          %Tables.Tag{name: :table},
          "\n",
          "Hello"
        ])

      assert data == [%Tables.Tag{name: :table}, "\n", "Hello"]
    end

    test "text includes a newline before the tag" do
      data =
        Tables.table_breathing_room([
          "Hello\n",
          %Tables.Tag{name: :table}
        ])

      assert data == ["Hello\n", %Tables.Tag{name: :table}]
    end

    test "text includes a newline after the tag" do
      data =
        Tables.table_breathing_room([
          %Tables.Tag{name: :table},
          "\nHello"
        ])

      assert data == [%Tables.Tag{name: :table}, "\nHello"]
    end
  end

  describe "validating the table" do
    test "valid table" do
      rows = [
        %Tables.Tag{
          name: :row,
          children: [
            %Tables.Tag{
              name: :cell,
              children: ["Hello, ", "World"]
            }
          ]
        }
      ]

      assert Tables.valid_rows?(rows)
    end

    test "rows contain things other than tags" do
      rows = [
        "Hello",
        %Tables.Tag{
          name: :row,
          children: [
            %Tables.Tag{
              name: :cell,
              children: ["Hello, ", "World"]
            }
          ]
        }
      ]

      refute Tables.valid_rows?(rows)
    end

    test "row cildren contain things other than tags" do
      rows = [
        %Tables.Tag{
          name: :row,
          children: [
            "Hello",
            %Tables.Tag{
              name: :cell,
              children: ["Hello, ", "World"]
            }
          ]
        }
      ]

      refute Tables.valid_rows?(rows)
    end
  end
end
