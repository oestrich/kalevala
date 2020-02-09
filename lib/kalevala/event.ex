defmodule Kalevala.Event do
  @moduledoc """
  An internal event
  """

  @type t() :: %__MODULE__{}

  @type topic() :: String.t()

  defstruct [:from_pid, :topic, :data]

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Conn
    end
  end
end

defmodule Kalevala.Event.Display do
  @moduledoc """
  An event to display text/data back to the user
  """

  defstruct lines: [], options: []
end

defmodule Kalevala.Event.CharacterUpdate do
  @moduledoc """
  Update the character in local lists
  """

  defstruct [:character]
end

defmodule Kalevala.Event.Move do
  @moduledoc """
  An event to move from one room to another
  """

  defstruct [:character, :direction, :reason, :room_id]
end
