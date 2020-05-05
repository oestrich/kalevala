defprotocol Kalevala.Character.Brain.Node do
  @moduledoc """
  Process a node in the behavior tree
  """

  def run(node, conn, event)
end

defmodule Kalevala.Character.Brain.NullNode do
  @moduledoc """
  A no-op node
  """

  defstruct []

  defimpl Kalevala.Character.Brain.Node do
    def run(_node, conn, _event), do: conn
  end
end

defmodule Kalevala.Character.Brain.FirstSelector do
  @moduledoc """
  Processes each node one at a time and stops processing when the first one succeeds
  """

  defstruct [:nodes]

  defimpl Kalevala.Character.Brain.Node do
    alias Kalevala.Character.Brain.Node

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

defmodule Kalevala.Character.Brain.ConditionalSelector do
  @moduledoc """
  Processes each node one at a time and stops processing when the first one fails
  """

  defstruct [:nodes]

  defimpl Kalevala.Character.Brain.Node do
    alias Kalevala.Character.Brain.Node

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

defmodule Kalevala.Character.Brain.RandomSelector do
  @moduledoc """
  Processes a random node
  """

  defstruct [:nodes]

  defimpl Kalevala.Character.Brain.Node do
    alias Kalevala.Character.Brain.Node

    def run(node, conn, event) do
      node =
        node.nodes
        |> Enum.shuffle()
        |> List.first()

      Node.run(node, conn, event)
    end
  end
end

defmodule Kalevala.Character.Brain.Sequence do
  @moduledoc """
  Process each node one at a time
  """

  defstruct [:nodes]

  defimpl Kalevala.Character.Brain.Node do
    alias Kalevala.Character.Brain.Node

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

defmodule Kalevala.Character.Brain.Condition do
  @moduledoc """
  Check if a condition is valid

  Returns error if it does not match
  """

  defstruct [:data, :type]

  @callback match?(Event.t(), Conn.t(), map()) :: boolean()

  defimpl Kalevala.Character.Brain.Node do
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

defmodule Kalevala.Character.Brain.Action do
  @moduledoc """
  Node to trigger an action
  """

  defstruct [:data, :type, delay: 0]

  @doc """
  Replace action data variables with event data
  """
  def replace(data, event_data) do
    Enum.into(data, %{}, fn {key, value} ->
      case is_binary(value) do
        true ->
          value = replace_variables(value, event_data)

          {to_string(key), value}

        false ->
          {to_string(key), value}
      end
    end)
  end

  @doc """
  Replace variables in a string value with a given map of data
  """
  def replace_variables(value, data) do
    variables = Regex.scan(~r/\$\{(?<variable>[\w\.]+)\}/, value)

    Enum.reduce(variables, value, fn [string, variable], value ->
      variable_path = String.split(variable, ".")
      variable_value = dereference(data, variable_path)
      String.replace(value, string, variable_value)
    end)
  end

  @doc """
  Dereference a variable path from a map of data
  """
  def dereference(data, variable_path) do
    Enum.reduce(variable_path, data, fn path, data ->
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

  defimpl Kalevala.Character.Brain.Node do
    alias Kalevala.Character.Brain.Action
    alias Kalevala.Character.Conn

    def run(node, conn, event) do
      data = Action.replace(node.data, event.data)

      Conn.put_action(conn, %Kalevala.Character.Action{
        type: node.type,
        params: data,
        delay: node.delay
      })
    end
  end
end

defmodule Kalevala.Character.Conditions.MessageMatch do
  @moduledoc """
  Condition check for the event being a message and the regex matches
  """

  @behaviour Kalevala.Character.Brain.Condition

  alias Kalevala.Event.Message

  @impl true
  def match?(event = %{topic: Message}, conn, data) do
    self_check(event, conn, data) && Regex.match?(data.text, event.data.text)
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
