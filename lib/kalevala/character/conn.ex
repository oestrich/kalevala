defmodule Kalevala.Character.Conn.Private do
  @moduledoc false

  alias Kalevala.World.Room

  defstruct [
    :character_module,
    :event_router,
    :next_controller,
    :request_id,
    :update_character,
    actions: [],
    channel_changes: [],
    halt?: false
  ]

  @doc """
  Generate a request id to track actions past usage in the conn
  """
  def generate_request_id() do
    bytes =
      Enum.reduce(1..16, <<>>, fn _, bytes ->
        bytes <> <<Enum.random(0..255)>>
      end)

    Base.encode16(bytes, case: :lower)
  end

  @doc false
  def character(conn) do
    character = conn.private.update_character || conn.character

    case is_nil(character) do
      true ->
        nil

      false ->
        meta = conn.private.character_module.trim_meta(character.meta)
        %{character | inventory: :trimmed, meta: meta}
    end
  end

  @doc false
  def default_event_router(conn) do
    case character(conn) do
      nil ->
        nil

      character ->
        {:global, name} = Room.global_name(character.room_id)
        :global.whereis_name(name)
    end
  end
end

defmodule Kalevala.Character.Conn.Event do
  @moduledoc """
  Send an out of band Event
  """

  @derive Jason.Encoder
  defstruct [:topic, :data]
end

defmodule Kalevala.Character.Conn.Lines do
  @moduledoc """
  Struct to print lines

  Used to determine if a new line should be sent before sending out
  new text.
  """

  defstruct [:data, newline: false, go_ahead: false]
end

defmodule Kalevala.Character.Conn.Option do
  @moduledoc """
  Telnet option
  """

  defstruct [:name, :value]
end

defmodule Kalevala.Character.Conn do
  @moduledoc """
  Struct for tracking data being processed in a controller or command
  """

  @type t() :: %__MODULE__{}

  alias Kalevala.Character.Conn.Private

  defstruct [
    :character,
    :params,
    assigns: %{},
    events: [],
    lines: [],
    options: [],
    private: %Private{},
    session: %{}
  ]

  @doc false
  def event_router(conn = %{private: %{event_router: nil}}),
    do: Private.default_event_router(conn)

  def event_router(%{private: %{event_router: event_router}}), do: event_router

  # Push text back to the user
  defp push(conn, event = %Kalevala.Character.Conn.Event{}, _newline) do
    Map.put(conn, :lines, conn.lines ++ [event])
  end

  defp push(conn, data, newline) do
    lines = %Kalevala.Character.Conn.Lines{
      data: data,
      newline: newline
    }

    Map.put(conn, :lines, conn.lines ++ [lines])
  end

  defp merge_assigns(conn, assigns) do
    conn.session
    |> Map.put(:character, Private.character(conn))
    |> Map.merge(conn.assigns)
    |> Map.merge(assigns)
  end

  @doc """
  Get the character out of the conn

  If the character has been updated, this character will be returned
  """
  def character(conn), do: Private.character(conn)

  @doc """
  Render text to the conn
  """
  def render(conn, view, template, assigns \\ %{}) do
    assigns = merge_assigns(conn, assigns)
    data = view.render(template, assigns)
    push(conn, data, false)
  end

  @doc """
  Render a prompt to the conn
  """
  def prompt(conn, view, template, assigns \\ %{}) do
    assigns = merge_assigns(conn, assigns)
    data = view.render(template, assigns)
    push(conn, data, true)
  end

  @doc """
  Add to the assignment map on the conn
  """
  def assign(conn, key, value) do
    assigns = Map.put(conn.assigns, key, value)
    Map.put(conn, :assigns, assigns)
  end

  @doc """
  Put a value into the session data
  """
  def put_session(conn, key, value) do
    session = Map.put(conn.session, key, value)
    Map.put(conn, :session, session)
  end

  @doc """
  Get a value out of the session data
  """
  def get_session(conn, key), do: Map.get(conn.session, key)

  @doc """
  Put the new controller that the foreman should swap to
  """
  def put_controller(conn, controller) do
    put_private(conn, :next_controller, controller)
  end

  @doc """
  Mark the connection for termination
  """
  def halt(conn) do
    private = Map.put(conn.private, :halt?, true)
    Map.put(conn, :private, private)
  end

  @doc """
  Send the foreman an in-game event
  """
  def event(conn, topic, data \\ %{}) do
    event = %Kalevala.Event{
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: topic,
      data: data
    }

    Map.put(conn, :events, conn.events ++ [event])
  end

  @doc """
  Delay an event
  """
  def delay_event(conn, delay, topic, data \\ %{}) do
    event = %Kalevala.Event.Delayed{
      delay: delay,
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: topic,
      data: data
    }

    Map.put(conn, :events, conn.events ++ [event])
  end

  @doc """
  Send a telnet option
  """
  def send_option(conn, name, value) when is_boolean(value) do
    option = %Kalevala.Character.Conn.Option{name: name, value: value}
    Map.put(conn, :options, conn.options ++ [option])
  end

  @doc """
  Request the room to move via the exit
  """
  def request_movement(conn, exit_name) do
    event = %Kalevala.Event{
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: Kalevala.Event.Movement.Request,
      data: %Kalevala.Event.Movement.Request{
        character: Private.character(conn),
        exit_name: exit_name
      }
    }

    event = Kalevala.Event.set_start_time(event)

    Map.put(conn, :events, conn.events ++ [event])
  end

  @doc """
  Creates an even to move from one room to another
  """
  def move(conn, direction, room_id, view, template, assigns) do
    assigns = merge_assigns(conn, assigns)
    data = view.render(template, assigns)

    event = %Kalevala.Event{
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: Kalevala.Event.Movement,
      data: %Kalevala.Event.Movement{
        character: Private.character(conn),
        direction: direction,
        reason: data,
        room_id: room_id
      }
    }

    Map.put(conn, :events, conn.events ++ [event])
  end

  @doc """
  Sends a request to drop an item into the room
  """
  def request_item_drop(conn, item_instance) do
    event = %Kalevala.Event{
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: Kalevala.Event.ItemDrop.Request,
      data: %Kalevala.Event.ItemDrop.Request{
        item_instance: item_instance
      }
    }

    Map.put(conn, :events, conn.events ++ [event])
  end

  @doc """
  Sends a request to get an item from the room
  """
  def request_item_pickup(conn, item_name) do
    event = %Kalevala.Event{
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: Kalevala.Event.ItemPickUp.Request,
      data: %Kalevala.Event.ItemPickUp.Request{
        item_name: item_name
      }
    }

    Map.put(conn, :events, conn.events ++ [event])
  end

  @doc """
  Update the character in state
  """
  def put_character(conn, character) do
    put_private(conn, :update_character, character)
  end

  @doc """
  Request to subscribe to a channel
  """
  def subscribe(conn, channel_name, options, error_fun) do
    options = Keyword.merge([character: Private.character(conn)], options)

    channel_changes = [
      {:subscribe, channel_name, options, error_fun} | conn.private.channel_changes
    ]

    put_private(conn, :channel_changes, channel_changes)
  end

  @doc """
  Request to unsubscribe from a channel
  """
  def unsubscribe(conn, channel_name, options, error_fun) do
    options = Keyword.merge([character: Private.character(conn)], options)

    channel_changes = [
      {:unsubscribe, channel_name, options, error_fun} | conn.private.channel_changes
    ]

    put_private(conn, :channel_changes, channel_changes)
  end

  @doc """
  Request to publish a message to a channel
  """
  def publish_message(conn, channel_name, text, options, error_fun) do
    event = %Kalevala.Event{
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: Kalevala.Event.Message,
      data: %Kalevala.Event.Message{
        channel_name: channel_name,
        character: Private.character(conn),
        text: text
      }
    }

    publish_channel_message(conn, channel_name, event, options, error_fun)
  end

  @doc """
  Request to publish an emote to a channel
  """
  def publish_emote(conn, channel_name, text, options, error_fun) do
    event = %Kalevala.Event{
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: Kalevala.Event.Message,
      data: %Kalevala.Event.Message{
        channel_name: channel_name,
        character: Private.character(conn),
        emote: true,
        text: text
      }
    }

    publish_channel_message(conn, channel_name, event, options, error_fun)
  end

  defp publish_channel_message(conn, channel_name, event, options, error_fun) do
    options = Keyword.merge([character: Private.character(conn)], options)

    channel_changes = [
      {:publish, channel_name, event, options, error_fun} | conn.private.channel_changes
    ]

    put_private(conn, :channel_changes, channel_changes)
  end

  @doc """
  Put an action to be performed

  This should be a `Kalevala.Character.Action` struct to save which
  action module should be run, along with any delay and params.
  """
  def put_action(conn, action = %Kalevala.Character.Action{}) do
    action = %{action | request_id: conn.private.request_id}
    put_private(conn, :actions, conn.private.actions ++ [action])
  end

  defp put_private(conn, key, value) do
    private = Map.put(conn.private, key, value)
    Map.put(conn, :private, private)
  end
end
