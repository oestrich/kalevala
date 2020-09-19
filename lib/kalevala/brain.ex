defprotocol Kalevala.Brain.Node do
  @moduledoc """
  Process a node in the behavior tree
  """

  def run(node, conn, event)
end

defmodule Kalevala.Brain.NullNode do
  @moduledoc """
  A no-op node
  """

  defstruct []

  defimpl Kalevala.Brain.Node do
    def run(_node, conn, _event), do: conn
  end
end

defmodule Kalevala.Brain.FirstSelector do
  @moduledoc """
  Processes each node one at a time and stops processing when the first one succeeds
  """

  defstruct [:nodes]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.Node

    def run(node, conn, event) do
      result =
        Enum.find_value(node.nodes, fn node ->
          case Node.run(node, conn, event) do
            :error ->
              false

            result ->
              result
          end
        end)

      case is_nil(result) do
        true ->
          conn

        false ->
          result
      end
    end
  end
end

defmodule Kalevala.Brain.ConditionalSelector do
  @moduledoc """
  Processes each node one at a time and stops processing when the first one fails
  """

  defstruct [:nodes]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.Node

    def run(node, conn, event) do
      Enum.reduce_while(node.nodes, conn, fn node, conn ->
        case Node.run(node, conn, event) do
          :error ->
            {:halt, :error}

          result ->
            {:cont, result}
        end
      end)
    end
  end
end

defmodule Kalevala.Brain.RandomSelector do
  @moduledoc """
  Processes a random node
  """

  defstruct [:nodes]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.Node

    def run(node, conn, event) do
      node =
        node.nodes
        |> Enum.shuffle()
        |> List.first()

      Node.run(node, conn, event)
    end
  end
end

defmodule Kalevala.Brain.Sequence do
  @moduledoc """
  Process each node one at a time
  """

  defstruct [:nodes]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.Node

    def run(node, conn, event) do
      Enum.reduce(node.nodes, conn, fn node, conn ->
        case Node.run(node, conn, event) do
          :error ->
            conn

          conn ->
            conn
        end
      end)
    end
  end
end

defmodule Kalevala.Brain.Condition do
  @moduledoc """
  Check if a condition is valid

  Returns error if it does not match
  """

  defstruct [:data, :type]

  @callback match?(Event.t(), Conn.t(), map()) :: boolean()

  defimpl Kalevala.Brain.Node do
    def run(node, conn, event) do
      case node.type.match?(event, conn, node.data) do
        true ->
          conn

        false ->
          :error
      end
    end
  end
end

defmodule Kalevala.Brain.Variable do
  @moduledoc """
  Handle variable data in brain nodes

  Replaces variables in the format of `${variable_name}`. Works with
  a dot notation for nested variables.

  Example:

  The starting data

       %{
         channel_name: "rooms:${room_id}",
         delay: 500,
         text: "Welcome, ${character.name}!"
       }

  With the event data

      %{
        room_id: "room-id",
        character: %{
          name: "Elias"
        }
      }

  Will replace to the following

       %{
         channel_name: "rooms:room-id",
         delay: 500,
         text: "Welcome, Elias!"
       }
  """

  defstruct [:path, :original, :reference, :value]

  @doc """
  Replace action data variables with event data
  """
  def replace(data, event_data) do
    data
    |> detect_variables()
    |> dereference_variables(event_data)
    |> replace_variables(data)
  end

  @doc """
  Detect variables inside of the data
  """
  def detect_variables(data, path \\ []) do
    data
    |> Enum.map(fn {key, value} ->
      find_variables({key, value}, path)
    end)
    |> Enum.reject(&is_nil/1)
    |> List.flatten()
  end

  defp find_variables({key, value}, path) when is_binary(value) do
    variables(value, path ++ [key])
  end

  defp find_variables({key, value}, path) when is_map(value) do
    detect_variables(value, path ++ [key])
  end

  defp find_variables(_, _), do: nil

  @doc """
  Scan the value for a variable, returning `Variable` structs
  """
  def variables(value, path) do
    Enum.map(Regex.scan(~r/\$\{(?<variable>[\w\.]+)\}/, value), fn [string, variable] ->
      %Kalevala.Brain.Variable{
        path: path,
        original: string,
        reference: variable
      }
    end)
  end

  def dereference_variables(variables, event_data) do
    Enum.map(variables, fn variable ->
      dereference_variable(variable, event_data)
    end)
  end

  defp dereference_variable(variables, event_data) when is_list(variables) do
    Enum.map(variables, fn variable ->
      dereference_variable(variable, event_data)
    end)
  end

  defp dereference_variable(variable, event_data) do
    variable_reference = String.split(variable.reference, ".")
    variable_value = dereference(event_data, variable_reference)
    %{variable | value: variable_value}
  end

  @doc """
  Replace detected and dereferenced variables in the data

  Fails if any variables still contain an `:error` value, they were
  not able to be dereferenced.
  """
  def replace_variables(variables, data) do
    failed_replace? =
      Enum.any?(variables, fn variable ->
        variable.value == :error
      end)

    case failed_replace? do
      true ->
        :error

      false ->
        {:ok, Enum.reduce(variables, data, &replace_variable/2)}
    end
  end

  defp replace_variable(variables, data) when is_list(variables) do
    Enum.reduce(variables, data, &replace_variable/2)
  end

  defp replace_variable(variable, data) do
    string = get_in(data, variable.path)
    string = String.replace(string, variable.original, variable.value)
    put_in(data, variable.path, string)
  end

  @doc """
  Dereference a variable path from a map of data
  """
  def dereference(data, variable_path) do
    Enum.reduce(variable_path, data, fn
      _path, nil ->
        :error

      _path, :error ->
        :error

      path, data ->
        data =
          Enum.into(maybe_destruct(data), %{}, fn {key, value} ->
            {to_string(key), value}
          end)

        Map.get(data, path)
    end)
  end

  defp maybe_destruct(data = %{__struct__: struct}) when not is_nil(struct) do
    Map.from_struct(data)
  end

  defp maybe_destruct(data), do: data

  @doc """
  Walk the resulting data map to convert keys from atoms to strings

  This is useful when sending the resulting data struct to action params
  """
  def stringify_keys(nil), do: nil

  def stringify_keys(map) when is_map(map) do
    Enum.into(map, %{}, fn {k, v} ->
      {to_string(k), stringify_keys(v)}
    end)
  end

  def stringify_keys([head | rest]) do
    [stringify_keys(head) | stringify_keys(rest)]
  end

  def stringify_keys(value), do: value
end

defmodule Kalevala.Brain.Action do
  @moduledoc """
  Node to trigger an action
  """

  defstruct [:data, :type, delay: 0]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.Variable
    alias Kalevala.Character.Conn

    def run(node, conn, event) do
      character = Conn.character(conn, trim: true)
      event_data = Map.merge(Map.from_struct(character), event.data)

      case Variable.replace(node.data, event_data) do
        {:ok, data} ->
          data = Variable.stringify_keys(data)

          Conn.put_action(conn, %Kalevala.Character.Action{
            type: node.type,
            params: data,
            delay: node.delay
          })

        :error ->
          conn
      end
    end
  end
end

defmodule Kalevala.Brain.MetaSet do
  @moduledoc """
  Node to set meta values on a character
  """

  defstruct [:data]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.Variable
    alias Kalevala.Character.Conn
    alias Kalevala.Meta

    def run(node, conn, event) do
      character = Conn.character(conn)

      event_data = Map.merge(Map.from_struct(character), event.data)

      case Variable.replace(node.data, event_data) do
        {:ok, data} ->
          meta = Meta.put(character.meta, data.key, data.value)
          character = %{character | meta: meta}
          Conn.put_character(conn, character)

        :error ->
          conn
      end
    end
  end
end

defmodule Kalevala.Brain.Conditions.EventMatch do
  @moduledoc """
  Condition check for the event being a message and the regex matches
  """

  @behaviour Kalevala.Brain.Condition

  @impl true
  def match?(event, conn, data) do
    self_check(event, conn, data) && data.topic == event.topic &&
      Enum.all?(data.data, fn {key, value} ->
        Map.get(event.data, key) == value
      end)
  end

  def self_check(event, conn, %{self_trigger: self_trigger}) do
    acting_character = Map.get(event, :acting_character) || %{}

    case Map.get(acting_character, :id) == conn.character.id do
      true ->
        self_trigger

      false ->
        true
    end
  end
end

defmodule Kalevala.Brain.Conditions.MessageMatch do
  @moduledoc """
  Condition check for the event being a message and the regex matches
  """

  @behaviour Kalevala.Brain.Condition

  alias Kalevala.Event.Message

  @impl true
  def match?(event = %{topic: Message}, conn, data) do
    data.interested?.(event) &&
      self_check(event, conn, data) &&
      Regex.match?(data.text, event.data.text)
  end

  def match?(_event, _conn, _data), do: false

  def self_check(event, conn, %{self_trigger: self_trigger}) do
    case event.acting_character.id == conn.character.id do
      true ->
        self_trigger

      false ->
        true
    end
  end
end

defmodule Kalevala.Brain.Conditions.MetaMatch do
  @moduledoc """
  Match values in the meta map
  """

  alias Kalevala.Brain.Variable
  alias Kalevala.Character.Conn
  alias Kalevala.Meta

  @behaviour Kalevala.Brain.Condition

  @impl true
  def match?(event, conn, data = %{match: match}) do
    character = Conn.character(conn)
    event_data = Map.merge(Map.from_struct(character), event.data)

    case Variable.replace(data, event_data) do
      {:ok, data} ->
        case match do
          "equality" ->
            Meta.get(character.meta, data.key) == data.value

          "inequality" ->
            Meta.get(character.meta, data.key) != data.value
        end

      :error ->
        false
    end
  end
end
