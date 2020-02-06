defmodule Kalevala.Conn.Private do
  @moduledoc false

  defstruct [:view]
end

defmodule Kalevala.Conn do
  @moduledoc """
  Struct for tracking data being processed in a command or action
  """

  @type t() :: %__MODULE__{}

  defstruct [
    :next_controller,
    assigns: %{},
    lines: [],
    private: %Kalevala.Conn.Private{},
    session: %{}
  ]
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
