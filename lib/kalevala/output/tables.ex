defmodule Kalevala.Output.Tables.Tag do
  @moduledoc false

  defstruct [:name, attributes: %{}, children: []]

  def append(tag, child) do
    %{tag | children: tag.children ++ [child]}
  end
end

defmodule Kalevala.Output.Tables do
  @moduledoc """
  Process table tags into ANSI tables
  """

  use Kalevala.Output

  import Kalevala.Character.View.Macro, only: [sigil_i: 2]

  alias Kalevala.Character.View
  alias Kalevala.Output.Tables.Tag

  @impl true
  def init(opts) do
    %Context{
      data: [],
      opts: opts,
      meta: %{
        current_tag: :empty,
        tag_stack: []
      }
    }
  end

  @impl true
  def parse({:open, "table", attributes}, context) do
    parse_open(context, :table, attributes)
  end

  def parse({:open, "row", attributes}, context) do
    parse_open(context, :row, attributes)
  end

  def parse({:open, "cell", attributes}, context) do
    parse_open(context, :cell, attributes)
  end

  def parse({:close, "table"}, context) do
    parse_close(context)
  end

  def parse({:close, "row"}, context) do
    parse_close(context)
  end

  def parse({:close, "cell"}, context) do
    parse_close(context)
  end

  def parse(datum, context) do
    case context.meta.current_tag == :empty do
      true ->
        Map.put(context, :data, context.data ++ [datum])

      false ->
        current_tag = Tag.append(context.meta.current_tag, datum)
        meta = Map.put(context.meta, :current_tag, current_tag)
        Map.put(context, :meta, meta)
    end
  end

  defp parse_open(context, tag, attributes) do
    tag_stack = [context.meta.current_tag | context.meta.tag_stack]

    meta =
      context.meta
      |> Map.put(:current_tag, %Tag{name: tag, attributes: attributes})
      |> Map.put(:tag_stack, tag_stack)

    Map.put(context, :meta, meta)
  end

  defp parse_close(context) do
    [new_current | tag_stack] = context.meta.tag_stack

    current_tag = context.meta.current_tag
    current_tag = %{current_tag | children: current_tag.children}

    case new_current do
      :empty ->
        meta =
          context.meta
          |> Map.put(:current_tag, :empty)
          |> Map.put(:tag_stack, tag_stack)

        context
        |> Map.put(:data, context.data ++ [current_tag])
        |> Map.put(:meta, meta)

      new_current ->
        meta =
          context.meta
          |> Map.put(:current_tag, Tag.append(new_current, current_tag))
          |> Map.put(:tag_stack, tag_stack)

        Map.put(context, :meta, meta)
    end
  end

  @impl true
  def post_parse(context) do
    data =
      context.data
      |> table_breathing_room()
      |> Enum.map(&parse_data/1)

    case Enum.any?(data, &match?(:error, &1)) do
      true ->
        :error

      false ->
        Map.put(context, :data, data)
    end
  end

  @doc """
  Give table tags some "breathing" room

  - If there is text before the table and no newline, then make a new line
  - If there is text after the table and no newline, then make a new line
  """
  def table_breathing_room([]), do: []

  def table_breathing_room([datum, table = %Tag{name: :table} | data])
      when datum not in ["", "\n"] do
    [datum, "\n" | table_breathing_room([table | data])]
  end

  def table_breathing_room([table = %Tag{name: :table}, datum | data])
      when datum not in ["", "\n"] do
    [table, "\n" | table_breathing_room([datum, data])]
  end

  def table_breathing_room([datum | data]) do
    [datum | table_breathing_room(data)]
  end

  defp parse_data(%Tag{name: :table, children: children}) do
    parse_table(children)
  end

  defp parse_data(datum), do: datum

  defp parse_table(rows) do
    rows =
      rows
      |> trim_children()
      |> Enum.map(fn row ->
        cells = trim_children(row.children)
        %{row | children: cells}
      end)

    case valid_rows?(rows) do
      true ->
        display_rows(rows)

      false ->
        :error
    end
  end

  defp trim_children([]), do: []

  defp trim_children([child | children]) when is_binary(child) do
    child = String.trim(child)

    case child == "" do
      true ->
        trim_children(children)

      false ->
        [child | trim_children(children)]
    end
  end

  defp trim_children([child = %Tag{} | children]) do
    [child | trim_children(children)]
  end

  defp valid_rows?(rows) do
    Enum.all?(rows, fn row ->
      match?(%Tag{name: :row}, row) && valid_cells?(row.children)
    end)
  end

  defp valid_cells?(cells) do
    Enum.all?(cells, fn cell ->
      match?(%Tag{name: :cell}, cell)
    end)
  end

  @doc """
  Display a table
  """
  def display_rows(rows) do
    width = max_width(rows)

    split_row = Enum.join(Enum.map(0..(width - 1), fn _i -> "-" end), "")

    rows = Enum.map(rows, &display_row(&1, width, split_row))

    [
      ~i(+#{split_row}+\n),
      View.join(rows, "\n")
    ]
  end

  @doc """
  Display a row's cells
  """
  def display_row(row, max_width, split_row) do
    width_difference = max_width - row_width(row)
    cell_padding = Float.floor(width_difference / Enum.count(row.children))

    [
      "| ",
      View.join(display_cells(row.children, cell_padding), " | "),
      " |\n",
      ["+", split_row, "+"]
    ]
  end

  @doc """
  Display a cell's contents

  Pads the left and right, "pulls" left when centering (if an odd number)
  """
  def display_cells(cells, cell_padding) do
    left_padding = cell_padding(Float.floor(cell_padding / 2))
    right_padding = cell_padding(Float.ceil(cell_padding / 2))

    Enum.map(cells, fn cell ->
      [left_padding, cell.children, right_padding]
    end)
  end

  @doc """
  Build a list of padding spaces for a side of a cell
  """
  def cell_padding(0.0), do: []

  def cell_padding(cell_padding) do
    Enum.map(1..trunc(cell_padding), fn _i ->
      " "
    end)
  end

  @doc """
  Find the max width of rows in a table
  """
  def max_width(rows) do
    rows
    |> Enum.max_by(&row_width/1)
    |> row_width()
  end

  @doc """
  Get the total width of a row

  Each cell tracks it's string width, plus 3 for built in padding
  """
  def row_width(row) do
    # - 1 for not tracking the final "|" of the row
    Enum.reduce(row.children, 0, fn cell, width ->
      children = Enum.filter(cell.children, &is_binary/1)

      # + 1 for cell barrier
      # + 2 for cell padding
      Enum.reduce(children, width, fn elem, width ->
        String.length(elem) + width
      end) + 3
    end) - 1
  end
end
