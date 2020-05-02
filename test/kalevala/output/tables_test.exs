defmodule Kalevala.Output.TablesTest do
  use ExUnit.Case

  alias Kalevala.Output.Tables

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
