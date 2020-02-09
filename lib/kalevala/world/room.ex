defmodule Kalevala.World.Room.Context do
  @moduledoc """
  Context for performing work for an event in a room
  """

  @type t() :: %__MODULE__{}

  defstruct [:data, assigns: %{}, events: [], lines: []]

  defp push(context, to_pid, event = %Kalevala.Conn.Event{}, _newline) do
    Map.put(context, :lines, context.lines ++ [{to_pid, event}])
  end

  defp push(context, to_pid, data, newline) do
    lines = %Kalevala.Conn.Lines{
      data: data,
      newline: newline
    }

    Map.put(context, :lines, context.lines ++ [{to_pid, lines}])
  end

  @doc """
  Render text back to a pid
  """
  def render(context, to_pid, view, template, assigns) do
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
  def event(context, to_pid, topic, data) do
    event = %Kalevala.Event{
      from_pid: self(),
      topic: topic,
      data: data
    }

    Map.put(context, :events, context.events ++ [{to_pid, event}])
  end
end

defmodule Kalevala.World.Room.Movement do
  @moduledoc """
  Handle room movement
  """

  alias Kalevala.Event

  @doc """
  Handle the movement event
  """
  def handle_event(state, event = %Event.Move{direction: :to}) do
    lines = %Kalevala.Conn.Lines{data: event.reason, newline: true}
    display_event = %Event.Display{lines: [lines]}

    Enum.each(state.private.characters, fn character ->
      send(character.pid, display_event)
    end)

    characters = [event.character | state.private.characters]
    private = Map.put(state.private, :characters, characters)

    Map.put(state, :private, private)
  end

  def handle_event(state, event = %Event.Move{direction: :from}) do
    characters =
      Enum.reject(state.private.characters, fn character ->
        character.id == event.character.id
      end)

    lines = %Kalevala.Conn.Lines{data: event.reason, newline: true}
    display_event = %Event.Display{lines: [lines]}

    Enum.each(characters, fn character ->
      send(character.pid, display_event)
    end)

    private = Map.put(state.private, :characters, characters)
    Map.put(state, :private, private)
  end
end

defmodule Kalevala.World.Room.Private do
  @moduledoc """
  Store private information for a room, e.g. characters in the room
  """

  defstruct characters: []
end

defmodule Kalevala.World.Room do
  @moduledoc """
  Rooms are the base unit of space in Kalevala
  """

  use GenServer

  require Logger

  alias Kalevala.Event
  alias Kalevala.World.Room.Context
  alias Kalevala.World.Room.Movement
  alias Kalevala.World.Room.Private

  defstruct [
    :id,
    :zone_id,
    :name,
    :description,
    exits: []
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Called when the zone is initializing
  """
  @callback init(zone :: t()) :: t()

  @doc """
  Callback for when a new event is received
  """
  @callback event(Context.t(), event :: Event.t()) :: t()

  defmacro __using__(_opts) do
    quote do
      import Kalevala.World.Room.Context

      @behaviour Kalevala.World.Room
    end
  end

  @doc false
  def global_name(room = %__MODULE__{}), do: global_name(room.id)

  def global_name(room_id), do: {:global, {__MODULE__, room_id}}

  @doc false
  def start_link(options) do
    otp_options = options.otp
    options = Map.delete(options, :otp)

    GenServer.start_link(__MODULE__, options, otp_options)
  end

  @impl true
  def init(state) do
    Logger.info("Room starting - #{state.room.id}")

    config = state.config
    room = config.callback_module.init(state.room)

    state = %{
      data: room,
      supervisor: config.supervisor,
      callback_module: config.callback_module,
      private: %Private{}
    }

    {:ok, state}
  end

  @impl true
  def handle_info(event = %Event{}, state) do
    context =
      %Context{data: state.data}
      |> state.callback_module.event(event)
      |> send_lines()
      |> send_events()

    state = Map.put(state, :data, context.data)

    {:noreply, state}
  end

  def handle_info(event = %Event.Move{}, state) do
    case event.room_id == state.data.id do
      true ->
        state = Movement.handle_event(state, event)
        {:noreply, state}

      false ->
        {:noreply, state}
    end
  end

  defp send_lines(context) do
    context.lines
    |> Enum.group_by(
      fn {to_pid, _line} ->
        to_pid
      end,
      fn {_to_pid, line} ->
        line
      end
    )
    |> Enum.each(fn {to_pid, lines} ->
      send(to_pid, %Event.Display{lines: lines})
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
