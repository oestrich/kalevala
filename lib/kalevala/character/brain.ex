defprotocol Kalevala.Character.Brain.Node do
  def run(node, conn, event)
end

defmodule Kalevala.Character.Brain.NullNode do
  defstruct []

  defimpl Kalevala.Character.Brain.Node do
    def run(_node, conn, _event), do: conn
  end
end

defmodule Kalevala.Character.Brain.FirstSelector do
  @doc """
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
  @doc """
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
  @doc """
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
  @doc """
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
  @callback run(Event.t(), Conn.t(), map()) :: :ok

  defstruct [:data, :type]

  defimpl Kalevala.Character.Brain.Node do
    def run(node, conn, event) do
      node.type.run(event, conn, node.data)
    end
  end
end

defmodule Kalevala.Character.Conditions.MessageMatch do
  @behaviour Kalevala.Character.Brain.Condition

  @impl true
  def match?(event, _conn, data) do
    event.topic == Kalevala.Event.Message && Regex.match?(data.text, event.data.text)
  end
end

defmodule Kalevala.Character.Actions.Say do
  @behaviour Kalevala.Character.Brain.Action

  import Kalevala.Character.Conn, only: [publish_message: 5]

  @impl true
  def run(event, conn, data) do
    publish_message(conn, event.data.channel_name, data.text, [], &publish_error/2)
  end

  def publish_error(conn, _error), do: conn
end

defmodule Kalevala.Character.Actions.Emote do
  @behaviour Kalevala.Character.Brain.Action

  import Kalevala.Character.Conn, only: [publish_emote: 5]

  @impl true
  def run(event, conn, data) do
    publish_emote(conn, event.data.channel_name, data.text, [], &publish_error/2)
  end

  def publish_error(conn, _error), do: conn
end
