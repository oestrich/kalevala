defmodule Kalevala.World.Room.Context do
  @moduledoc """
  Context for performing work for an event in a room
  """

  alias Kalevala.Event
  alias Kalevala.Meta
  alias Kalevala.World.Room.Handler

  @type t() :: %__MODULE__{}

  defstruct [:data, assigns: %{}, characters: [], events: [], item_instances: [], output: []]

  @doc """
  Create a new context struct from room state
  """
  def new(state) do
    item_instances =
      Enum.map(state.private.item_instances, fn item_instance ->
        %{item_instance | meta: Meta.trim(item_instance.meta)}
      end)

    characters =
      Enum.map(state.private.characters, fn character ->
        %{character | inventory: []}
      end)

    %__MODULE__{
      data: state.data,
      characters: characters,
      item_instances: item_instances
    }
  end

  defp push(context, to_pid, event = %Kalevala.Character.Conn.Event{}, _newline) do
    Map.put(context, :output, context.output ++ [{to_pid, event}])
  end

  defp push(context, to_pid, event = %Kalevala.Character.Conn.EventText{}, newline) do
    text = %Kalevala.Character.Conn.Text{
      data: event.text,
      newline: newline
    }

    event = %{event | text: text}

    Map.put(context, :output, context.output ++ [{to_pid, event}])
  end

  defp push(context, to_pid, data, newline) do
    text = %Kalevala.Character.Conn.Text{
      data: data,
      newline: newline
    }

    Map.put(context, :output, context.output ++ [{to_pid, text}])
  end

  @doc """
  Render text back to a pid
  """
  def render(context, to_pid, view, template, assigns \\ %{}) do
    assigns = Map.merge(context.assigns, assigns)
    data = view.render(template, assigns)
    push(context, to_pid, data, false)
  end

  @doc """
  Render a prompt back to a pid
  """
  def prompt(context, to_pid, view, template, assigns \\ %{}) do
    assigns = Map.merge(context.assigns, assigns)
    data = view.render(template, assigns)
    push(context, to_pid, data, true)
  end

  @doc """
  Add to the assignment map on the context
  """
  def assign(context, key, value) do
    assigns = Map.put(context.assigns, key, value)
    Map.put(context, :assigns, assigns)
  end

  @doc """
  Send an event back to a pid
  """
  def event(context, to_pid, from_pid, topic, data) do
    event = %Kalevala.Event{
      from_pid: from_pid,
      topic: topic,
      data: data
    }

    Map.put(context, :events, context.events ++ [{to_pid, event}])
  end

  @doc """
  Update the context data
  """
  def put_data(context, key, val) do
    data = Map.put(context.data, key, val)
    Map.put(context, :data, data)
  end

  @doc """
  Broadcast an event to multiple characters in the room
  """
  def broadcast(context, topic, data, opts \\ []) do
    recipients = Keyword.get(opts, :to, context.characters)

    recipients =
      case Keyword.get(opts, :except) do
        nil ->
          recipients

        keywords when is_list(keywords) ->
          Enum.reject(recipients, fn character ->
            Enum.any?(keywords, &Handler.match_character?(character, &1))
          end)

        keyword ->
          Enum.reject(recipients, &Handler.match_character?(&1, keyword))
      end

    Enum.reduce(recipients, context, fn character, acc ->
      event(acc, character.pid, self(), topic, data)
    end)
  end

  @doc """
  Handle context after processing an event
  """
  def handle_context(context) do
    context
    |> send_output()
    |> send_events()
  end

  defp send_output(context) do
    context.output
    |> Enum.group_by(
      fn {to_pid, _text} ->
        to_pid
      end,
      fn {_to_pid, text} ->
        text
      end
    )
    |> Enum.each(fn {to_pid, text} ->
      send(to_pid, %Event.Display{output: text})
    end)

    context
  end

  defp send_events(context) do
    Enum.each(context.events, fn {to_pid, event} ->
      send(to_pid, event)
    end)

    context
  end
end
