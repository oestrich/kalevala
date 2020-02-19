defmodule Kalevala.Event.Metadata do
  @moduledoc """
  Metadata for an event, used for telemetry
  """

  defstruct [:start_time, :end_time]
end

defmodule Kalevala.Event.Message do
  @moduledoc """
  Struct for sending a message
  """

  @type t() :: %__MODULE__{}

  defstruct [:channel_name, :character, :text, emote: false]
end

defmodule Kalevala.Event do
  @moduledoc """
  An internal event
  """

  @type t() :: %__MODULE__{}

  @type movement_request() :: %__MODULE__{
          topic: __MODULE__.Movement.Request
        }

  @type movement_voting() :: %__MODULE__{
          topic: __MODULE__.Movement.Voting
        }

  @type message() :: %__MODULE__{
          topic: __MODULE__.Message
        }

  @type topic() :: String.t()

  defstruct [:from_pid, :topic, :data, metadata: %__MODULE__.Metadata{}]

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Conn
    end
  end

  @doc """
  Set the start time on an event
  """
  def set_start_time(event) do
    update_metadata(event, %{event.metadata | start_time: System.monotonic_time()})
  end

  @doc """
  Set the end time on an event
  """
  def set_end_time(event) do
    update_metadata(event, %{event.metadata | end_time: System.monotonic_time()})
  end

  @doc """
  Timing for an event in microseconds
  """
  def timing(event) do
    event.metadata.end_time - event.metadata.start_time
  end

  defp update_metadata(event, metadata) do
    %{event | metadata: metadata}
  end
end

defmodule Kalevala.Event.Display do
  @moduledoc """
  An event to display text/data back to the user
  """

  defstruct lines: [], options: []
end
