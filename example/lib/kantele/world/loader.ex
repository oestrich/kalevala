defmodule Kantele.World.Loader do
  @moduledoc """
  Load the world from data files
  """

  alias Kalevala.Character
  alias Kalevala.World.Item
  alias Kalevala.World.Room
  alias Kalevala.World.Zone

  @doc """
  Load zone files into Kalevala structs
  """
  def load_world(path \\ "data/world") do
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
    |> Enum.map(&parse_characters(&1, data, zones))
    |> Enum.map(&parse_items(&1, data, zones))
    |> Enum.map(&zone_items_to_list/1)
    |> Enum.map(&zone_rooms_to_list/1)
    |> parse_world()
  end

  defp merge_zone_data(zone_data) do
    [key] = Map.keys(zone_data.zones)
    {to_string(key), zone_data}
  end

  defp zone_items_to_list(zone) do
    items = Map.values(zone.items)
    %{zone | items: items}
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

    characters = Map.get(zone_data, :characters, [])

    characters =
      Enum.into(characters, %{}, fn {key, character_data} ->
        parse_character(zone, key, character_data)
      end)

    items = Map.get(zone_data, :items, [])

    items =
      Enum.into(items, %{}, fn {key, item_data} ->
        parse_item(zone, key, item_data)
      end)

    %{zone | rooms: rooms, characters: characters, items: items}
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
  Parse character data

  ID is the zone's id concatenated with the character's key
  """
  def parse_character(zone, key, character_data) do
    character = %Character{
      id: "#{zone.id}:#{key}",
      name: character_data.name,
      description: character_data.description,
      meta: %Kantele.Character.NonPlayerMeta{
        zone_id: zone.id,
        brain: parse_brain(character_data),
        vitals: %Kantele.Character.Vitals{
          health_points: 25,
          max_health_points: 25,
          skill_points: 17,
          max_skill_points: 17,
          endurance_points: 30,
          max_endurance_points: 30
        }
      }
    }

    {key, character}
  end

  defp parse_brain(%{brain: brain}) do
    parse_node(brain)
  end

  defp parse_brain(_), do: %Kalevala.Character.Brain.NullNode{}

  defp parse_node(%{type: "sequence", nodes: nodes}) do
    %Kalevala.Character.Brain.Sequence{
      nodes: Enum.map(nodes, &parse_node/1)
    }
  end

  defp parse_node(%{type: "first", nodes: nodes}) do
    %Kalevala.Character.Brain.FirstSelector{
      nodes: Enum.map(nodes, &parse_node/1)
    }
  end

  defp parse_node(%{type: "conditional", nodes: nodes}) do
    %Kalevala.Character.Brain.ConditionalSelector{
      nodes: Enum.map(nodes, &parse_node/1)
    }
  end

  defp parse_node(%{type: "conditions/message-match", data: data}) do
    {:ok, regex} = Regex.compile(data.text, "i")

    %Kalevala.Character.Brain.Condition{
      type: Kalevala.Character.Conditions.MessageMatch,
      data: %{
        self_trigger: data.self_trigger == "true",
        text: regex
      }
    }
  end

  defp parse_node(%{type: "actions/say", data: data}) do
    %Kalevala.Character.Brain.Action{
      type: Kantele.Character.SayAction,
      data: data
    }
  end

  defp parse_node(%{type: "actions/emote", data: data}) do
    %Kalevala.Character.Brain.Action{
      type: Kantele.Character.EmoteAction,
      data: data
    }
  end

  defp parse_node(%{type: "actions/flee"}) do
    %Kalevala.Character.Brain.Action{
      type: Kantele.Character.FleeAction,
      data: %{}
    }
  end

  @doc """
  Parse item data

  ID is the zone's id concatenated with the item's key
  """
  def parse_item(zone, key, item_data) do
    item = %Item{
      id: "#{zone.id}:#{key}",
      name: item_data.name,
      description: item_data.description,
      callback_module: Kantele.World.Item,
      meta: %{}
    }

    {key, item}
  end

  @doc """
  Parse exits for zones

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
  Parse characters for zones

  Dereferences the world characters, creates structs and attachs them to the
  matching room.
  """
  def parse_characters(zone, data, zones) do
    zone_data = Map.get(data, zone.id)

    room_characters = Map.get(zone_data, :room_characters, [])

    characters =
      Enum.flat_map(room_characters, fn {_key, room_character} ->
        room_id = dereference(zones, zone, room_character.room_id)

        room_character.characters
        |> Enum.with_index()
        |> Enum.map(fn {character_data, index} ->
          character_id = dereference(zones, zone, character_data.id)

          {_key, character} = Enum.find(zone.characters, &match_character(&1, character_id))

          %Character{
            character
            | id: "#{room_id}:#{character.id}:#{index}",
              name: Map.get(character_data, :name, character.name),
              room_id: room_id
          }
        end)
      end)

    Enum.reduce(characters, zone, fn character, zone ->
      {room_key, room} =
        Enum.find(zone.rooms, fn {_key, room} ->
          room.id == character.room_id
        end)

      characters = Map.get(room, :characters, [])
      character = %{character | id: Character.generate_id()}
      room = Map.put(room, :characters, [character | characters])

      rooms = Map.put(zone.rooms, room_key, room)
      %{zone | rooms: rooms}
    end)
  end

  defp match_character({_key, character}, character_id), do: character.id == character_id

  @doc """
  Parse items for zones

  Dereferences the world items, creates structs and attachs them to the
  matching room.
  """
  def parse_items(zone, data, zones) do
    zone_data = Map.get(data, zone.id)

    room_items = Map.get(zone_data, :room_items, [])

    Enum.reduce(room_items, zone, fn {_key, room_item}, zone ->
      room_id = dereference(zones, zone, room_item.room_id)

      Enum.reduce(room_item.items, zone, fn item_data, zone ->
        item_id = dereference(zones, zone, item_data.id)
        parse_room_item(zone, room_id, item_id)
      end)
    end)
  end

  defp parse_room_item(zone, room_id, item_id) do
    instance = %Item.Instance{
      id: Item.Instance.generate_id(),
      item_id: item_id,
      created_at: DateTime.utc_now(),
      callback_module: Kantele.World.Item.Instance
    }

    {room_key, room} =
      Enum.find(zone.rooms, fn {_key, room} ->
        room.id == room_id
      end)

    item_instances = Map.get(room, :item_instances, [])
    room = Map.put(room, :item_instances, [instance | item_instances])

    rooms = Map.put(zone.rooms, room_key, room)
    %{zone | rooms: rooms}
  end

  @doc """
  Strip a zone of extra information that Kalevala doesn't care about
  """
  def strip_zone(zone) do
    zone
    |> Map.put(:characters, [])
    |> Map.put(:items, [])
    |> Map.put(:rooms, [])
  end

  @doc """
  Dereference a variable to it's value

  If a known key is found, use the current zone
  """
  def dereference(zones, zone, reference) do
    [key | reference] = String.split(reference, ".")

    case key in ["characters", "rooms", "items"] do
      true ->
        zone
        |> flatten_characters()
        |> flatten_items()
        |> flatten_rooms()
        |> dereference([key | reference])

      false ->
        zone =
          Enum.find(zones, fn z ->
            z.id == key
          end)

        zone
        |> flatten_characters()
        |> flatten_items()
        |> flatten_rooms()
        |> dereference(reference)
    end
  end

  defp flatten_characters(zone) do
    characters = Map.values(zone.characters)
    Map.put(zone, :characters, characters)
  end

  defp flatten_items(zone) do
    items = Map.values(zone.items)
    Map.put(zone, :items, items)
  end

  defp flatten_rooms(zone) do
    rooms = Map.values(zone.rooms)
    Map.put(zone, :rooms, rooms)
  end

  @doc """
  Convert zones into a world struct
  """
  def parse_world(zones) do
    world = %Kantele.World{
      zones: zones
    }

    world
    |> split_out_rooms()
    |> split_out_characters()
    |> split_out_items()
  end

  defp split_out_rooms(world) do
    Enum.reduce(world.zones, world, fn zone, world ->
      rooms =
        Enum.map(zone.rooms, fn room ->
          Map.delete(room, :characters)
        end)

      Map.put(world, :rooms, rooms ++ world.rooms)
    end)
  end

  defp split_out_characters(world) do
    Enum.reduce(world.zones, world, fn zone, world ->
      characters =
        Enum.flat_map(zone.rooms, fn room ->
          Map.get(room, :characters, [])
        end)

      Map.put(world, :characters, characters ++ world.characters)
    end)
  end

  defp split_out_items(world) do
    Enum.reduce(world.zones, world, fn zone, world ->
      Map.put(world, :items, zone.items ++ world.items)
    end)
  end

  @doc """
  Dereference a variable for a specific zone
  """
  def dereference(zone, reference) when is_list(reference) do
    case reference do
      ["characters" | character] ->
        [character_name, character_key] = character

        zone.characters
        |> find_character(zone, character_name)
        |> Map.get(String.to_atom(character_key))

      ["items" | item] ->
        [item_name, item_key] = item

        zone.items
        |> find_item(zone, item_name)
        |> Map.get(String.to_atom(item_key))

      ["rooms" | room] ->
        [room_name, room_key] = room

        zone.rooms
        |> find_room(zone, room_name)
        |> Map.get(String.to_atom(room_key))
    end
  end

  defp find_character(characters, zone, character_name) do
    Enum.find(characters, fn character ->
      character.id == "#{zone.id}:#{character_name}"
    end)
  end

  defp find_item(items, zone, item_name) do
    Enum.find(items, fn item ->
      item.id == "#{zone.id}:#{item_name}"
    end)
  end

  defp find_room(rooms, zone, room_name) do
    Enum.find(rooms, fn room ->
      room.id == "#{zone.id}:#{room_name}"
    end)
  end
end
