defmodule Kalevala.Conn.Private do
  @moduledoc false

  alias Kalevala.World.Room

  defstruct [:event_router, :view, halt?: false]

  @doc false
  def default_event_router(conn) do
    case Map.get(conn.session, :character) do
      nil ->
        nil

      character ->
        {:global, name} = Room.global_name(character.room_id)
        :global.whereis_name(name)
    end
  end
end

defmodule Kalevala.Conn do
  @moduledoc """
  Struct for tracking data being processed in a controller or command
  """

  @type t() :: %__MODULE__{}

  alias Kalevala.Conn.Private

  defstruct [
    :next_controller,
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
end

defmodule Kalevala.Conn.Event do
  @moduledoc """
  Send an out of band Event
  """

  defstruct [:topic, :data]
end

defmodule Kalevala.Conn.Lines do
  @moduledoc """
  Struct to print lines

  Used to determine if a new line should be sent before sending out
  new text.
  """

  defstruct [:data, newline: false, go_ahead: false]
end

defmodule Kalevala.Conn.Option do
  @moduledoc """
  Telnet option
  """

  defstruct [:name, :value]
end
