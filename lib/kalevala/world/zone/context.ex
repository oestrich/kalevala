defmodule Kalevala.World.Zone.Context do
  @moduledoc """
  Context for performing work for an event in a room
  """

  @type t() :: %__MODULE__{}

  defstruct [:data, events: []]

  @doc """
  Create a new context struct from room state
  """
  def new(state) do
    %__MODULE__{
      data: state.data
    }
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
  Handle context after processing an event
  """
  def handle_context(context) do
    send_events(context)
  end

  defp send_events(context) do
    Enum.each(context.events, fn {to_pid, event} ->
      send(to_pid, event)
    end)

    context
  end
end
