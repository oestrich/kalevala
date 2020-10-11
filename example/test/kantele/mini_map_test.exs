defmodule Kantele.MiniMapTest do
  use ExUnit.Case, async: true

  alias Kantele.MiniMap
  alias Kantele.MiniMap.Cell
  alias Kantele.MiniMap.Connections

  describe "generating a map" do
    test "calculates the full dimensions of the map" do
      {{min_x, max_x}, {min_y, max_y}, {min_z, max_z}} = MiniMap.size_of_map(generate_mini_map())

      assert min_x == -3
      assert max_x == 1
      assert min_y == 0
      assert max_y == 2
      assert min_z == 0
      assert max_z == 1
    end

    test "expands the map to display size" do
      expanded_map = MiniMap.expand_character_map({{-2, 1}, {0, 2}, {0, 0}})

      # top left
      assert Map.get(expanded_map, {-10, 5, 0}) == " "

      # top right
      assert Map.get(expanded_map, {5, 5, 0}) == " "

      # bottom left
      assert Map.get(expanded_map, {-10, -1, 0}) == " "

      # bottom right
      assert Map.get(expanded_map, {5, -1, 0}) == " "
    end

    test "fills in the expanded map with display characters" do
      mini_map = generate_mini_map()

      expanded_map =
        mini_map
        |> MiniMap.size_of_map()
        |> MiniMap.expand_character_map()
        |> MiniMap.fill_in(mini_map)

      assert Map.get(expanded_map, {-1, 0, 0}) == "["
      assert Map.get(expanded_map, {0, 0, 0}) == " "
      assert Map.get(expanded_map, {1, 0, 0}) == "]"
    end

    test "fully displays the map" do
      mini_map = MiniMap.display(generate_mini_map())

      assert to_string(mini_map) ==
               to_string([
                 "                     \n",
                 "     [ ]             \n",
                 "      |              \n",
                 " [ ]-[ ]-[ ]-[ ]     \n",
                 "              |      \n",
                 "             [ ]-[ ] \n",
                 "                     "
               ])
    end
  end

  def generate_mini_map() do
    %MiniMap{
      cells: %{
        {0, 0, 0} => %Cell{x: 0, y: 0, z: 0, connections: %Connections{north: true, east: true}},
        {0, 0, 1} => %Cell{x: 0, y: 0, z: 1},
        {1, 0, 0} => %Cell{x: 1, y: 0, z: 0, connections: %Connections{west: true}},
        {0, 1, 0} => %Cell{x: 0, y: 1, z: 0, connections: %Connections{south: true, west: true}},
        {-1, 1, 0} => %Cell{x: -1, y: 1, z: 0, connections: %Connections{east: true, west: true}},
        {-2, 2, 0} => %Cell{x: -2, y: 2, z: 0, connections: %Connections{south: true}},
        {-2, 1, 0} => %Cell{
          x: -2,
          y: 1,
          z: 0,
          connections: %Connections{north: true, east: true, west: true}
        },
        {-3, 1, 0} => %Cell{x: -3, y: 1, z: 0, connections: %Connections{east: true}}
      }
    }
  end
end
