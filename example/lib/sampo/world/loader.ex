defmodule Sampo.World.Loader do
  @moduledoc """
  Load the world from data files
  """

  alias Kalevala.World.Room
  alias Kalevala.World.Zone

  @doc """
  Load zone files into Kalevala structs
  """
  def load_zones(path \\ "data/world") do
    data =
      File.ls!(path)
      |> Enum.filter(fn file ->
        String.ends_with?(file, ".zone")
      end)
      |> Enum.map(fn file ->
        File.read!(Path.join("data/world", file))
      end)
      |> Enum.map(&Elias.parse/1)
      |> Enum.into(%{}, &merge_zone_data/1)

    zones = Enum.map(data, &parse_zone/1)

    zones
    |> Enum.map(&parse_exits(&1, data, zones))
    |> Enum.map(&zone_rooms_to_list/1)
  end

  defp merge_zone_data(zone_data) do
    [key] = Map.keys(zone_data.zones)
    {to_string(key), zone_data}
  end

  defp zone_rooms_to_list(zone) do
    rooms = Map.values(zone.rooms)
    %{zone | rooms: rooms}
  end

  @doc """
  Parse a zone

  Loads basic data and rooms
  """
  def parse_zone({key, zone_data}) do
    zone = %Zone{}

    name = get_in(zone_data.zones, [String.to_atom(key), :name])
    zone = %{zone | id: key, name: name}

    rooms = Map.get(zone_data, :rooms, [])

    rooms =
      Enum.into(rooms, %{}, fn {key, room_data} ->
        parse_room(zone, key, room_data)
      end)

    %{zone | rooms: rooms}
  end

  @doc """
  Parse room data

  ID is the zone's id concatenated with the room's key
  """
  def parse_room(zone, key, room_data) do
    room = %Room{
      id: "#{zone.id}:#{key}",
      zone_id: zone.id,
      name: room_data.name,
      description: room_data.description,
      features: parse_features(room_data)
    }

    {key, room}
  end

  def parse_features(%{features: features}) when is_list(features) do
    Enum.map(features, fn feature ->
      %Room.Feature{
        id: feature.keyword,
        keyword: feature.keyword,
        short_description: feature.short,
        description: feature.long
      }
    end)
  end

  def parse_features(_), do: []

  @doc """
  Parse exits for a zones

  Dereferences the exit exit_names, creates structs for each exit_name,
  and attaches them to the matching room.
  """
  def parse_exits(zone, data, zones) do
    zone_data = Map.get(data, zone.id)

    room_exits = Map.get(zone_data, :room_exits, [])

    exits =
      Enum.flat_map(room_exits, fn {_key, room_exit} ->
        room_exit =
          Enum.into(room_exit, %{}, fn {key, value} ->
            {key, dereference(zones, zone, value)}
          end)

        room_id = room_exit.room_id
        room_exit = Map.delete(room_exit, :room_id)

        Enum.map(room_exit, fn {key, value} ->
          %Kalevala.World.Exit{
            id: "#{room_id}:#{key}",
            exit_name: to_string(key),
            start_room_id: room_id,
            end_room_id: value
          }
        end)
      end)

    Enum.reduce(exits, zone, fn exit, zone ->
      {room_key, room} =
        Enum.find(zone.rooms, fn {_key, room} ->
          room.id == exit.start_room_id
        end)

      room = %{room | exits: [exit | room.exits]}

      rooms = Map.put(zone.rooms, room_key, room)
      %{zone | rooms: rooms}
    end)
  end

  @doc """
  Dereference a variable to it's value

  If a known key is found, use the current zone
  """
  def dereference(zones, zone, reference) do
    [key | reference] = String.split(reference, ".")

    case key in ["rooms"] do
      true ->
        zone
        |> flatten_rooms()
        |> dereference([key | reference])

      false ->
        zone =
          Enum.find(zones, fn z ->
            z.id == key
          end)

        zone
        |> flatten_rooms()
        |> dereference(reference)
    end
  end

  defp flatten_rooms(zone) do
    rooms = Map.values(zone.rooms)
    Map.put(zone, :rooms, rooms)
  end

  @doc """
  Dereference a variable for a specific zone
  """
  def dereference(zone, reference) when is_list(reference) do
    case reference do
      ["rooms" | room] ->
        [room_name, room_key] = room

        zone.rooms
        |> find_room(zone, room_name)
        |> Map.get(String.to_atom(room_key))
    end
  end

  defp find_room(rooms, zone, room_name) do
    Enum.find(rooms, fn room ->
      room.id == "#{zone.id}:#{room_name}"
    end)
  end
end
