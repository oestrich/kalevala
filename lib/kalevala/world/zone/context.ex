defmodule Kalevala.World.Zone.Context do
  @moduledoc """
  Context for performing work for an event in a room
  """

  alias Kalevala.Event

  @type t() :: %__MODULE__{}

  defstruct [:data, events: [], output: [], assigns: %{}]

  @doc """
  Create a new context struct from room state
  """
  def new(state) do
    %__MODULE__{
      data: state.data
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
  def prompt(context, to_pid, view, template, assigns) do
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
  Send an event to a pid on a delay
  """

  def delay_event(context, delay, to_pid, topic, data) do
    event = %Kalevala.Event.Delayed{
      delay: delay,
      from_pid: self(),
      topic: topic,
      data: data
    }

    Map.put(context, :events, context.events ++ [{self(), event}])
  end

  @doc """
  Update the context data
  """
  def put_data(context, key, val) do
    data = Map.put(context.data, key, val)
    Map.put(context, :data, data)
  end

  @doc """
  Handle context after processing an event
  """
  def handle_context(context) do
    context
    |> send_events()
    |> send_output()
  end

  defp send_events(context) do
    {events, delayed_events} =
      Enum.split_with(context.events, fn {_, event} ->
        match?(%Kalevala.Event{}, event)
      end)

    Enum.each(events, fn {to_pid, event} ->
      send(to_pid, event)
    end)

    Enum.each(delayed_events, fn {to_pid, delayed_event} ->
      Process.send_after(to_pid, delayed_event, delayed_event.delay)
    end)

    context
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
end
