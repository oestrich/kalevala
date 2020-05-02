defprotocol Kalevala.Character.Brain.Node do
  def run(node, event)
end

defmodule Kalevala.Character.Brain.FirstSelector do
  @doc """
  Processes each node one at a time and stops processing when the first one succeeds
  """

  defstruct [:nodes]

  defimpl Kalevala.Character.Brain.Node do
    alias Kalevala.Character.Brain.Node

    def run(node, event) do
      Enum.find(node.nodes, fn node ->
        case Node.run(node, event) do
          :error ->
            false

          result ->
            result
        end
      end)
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

    def run(node, event) do
      Enum.reduce_while(node.nodes, nil, fn node, _acc ->
        case Node.run(node, event) do
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

    def run(node, event) do
      node =
        node.nodes
        |> Enum.shuffle()
        |> List.first()

      Node.run(node, event)
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

    def run(node, event) do
      Enum.each(node.nodes, fn node ->
        Node.run(node, event)
      end)
    end
  end
end

defmodule Kalevala.Character.Brain.Condition do
  defstruct [:data, :type]

  @callback match?(Event.t(), map()) :: boolean()

  defimpl Kalevala.Character.Brain.Node do
    def run(node, event) do
      case node.type.match?(event, node.data) do
        true ->
          true

        false ->
          :error
      end
    end
  end
end

defmodule Kalevala.Character.Brain.Action do
  @callback run(Event.t(), map()) :: :ok

  defstruct [:data, :type]

  defimpl Kalevala.Character.Brain.Node do
    def run(node, event) do
      node.type.run(event, node.data)
    end
  end
end

defmodule Kalevala.Character.Conditions.MessageMatch do
  @behaviour Kalevala.Character.Brain.Condition

  @impl true
  def match?(event, data) do
    event.topic == Kalevala.Event.Message && Regex.match?(data.text, event.data.text)
  end
end

defmodule Kalevala.Character.Actions.Say do
  @behaviour Kalevala.Character.Brain.Action

  @impl true
  def run(_event, data) do
    IO.puts("#{IO.ANSI.yellow()}Person#{IO.ANSI.reset()} says, \"" <> data.text <> "\"")
  end
end

defmodule Kalevala.Character.Actions.Emote do
  @behaviour Kalevala.Character.Brain.Action

  @impl true
  def run(_event, data) do
    IO.puts("#{IO.ANSI.yellow()}Person#{IO.ANSI.reset()} " <> data.text)
  end
end

defmodule Kalevala.Character.Brain do
  alias Kalevala.Character.Brain.Node

  alias Kalevala.Character.Brain.FirstSelector
  alias Kalevala.Character.Brain.ConditionalSelector
  alias Kalevala.Character.Brain.Sequence

  alias Kalevala.Character.Brain.Action
  alias Kalevala.Character.Brain.Condition

  def run(text) do
    event = %Kalevala.Event{
      topic: Kalevala.Event.Message,
      data: %{
        channel_name: "general",
        text: text
      }
    }

    Node.run(first(), event)
  end

  def first() do
    %Sequence{
      nodes: [
        %FirstSelector{
          nodes: [
            %ConditionalSelector{
              nodes: [
                %Condition{
                  type: Kalevala.Character.Conditions.MessageMatch,
                  data: %{
                    text: ~r/hi/i
                  }
                },
                %Action{
                  type: Kalevala.Character.Actions.Say,
                  data: %{
                    text: "How are you?"
                  }
                }
              ]
            },
            %ConditionalSelector{
              nodes: [
                %Condition{
                  type: Kalevala.Character.Conditions.MessageMatch,
                  data: %{
                    text: ~r/goblin/i
                  }
                },
                %Action{
                  type: Kalevala.Character.Actions.Say,
                  data: %{
                    text: "I have a quest for you."
                  }
                }
              ]
            }
          ]
        },
        %ConditionalSelector{
          nodes: [
            %Condition{
              type: Kalevala.Character.Conditions.MessageMatch,
              data: %{
                text: ~r/boo/i
              }
            },
            %Action{
              type: Kalevala.Character.Actions.Emote,
              data: %{
                text: "hides behind a desk"
              }
            }
          ]
        }
      ]
    }
  end
end
