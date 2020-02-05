defmodule Kalevala.Conn.Private do
  @moduledoc false

  defstruct [:view]
end

defmodule Kalevala.Conn do
  @moduledoc """
  Struct for tracking data being processed in a command or action
  """

  defstruct [
    :params,
    :assigns,
    messages: [],
    private: %Kalevala.Conn.Private{},
    lines: []
  ]
end

defmodule Kalevala.Conn.Event do
  @moduledoc """
  Send an out of band Event
  """

  defstruct [:topic, :data]
end

defmodule Kalevala.Conn.Prompt do
  @moduledoc """
  An event to print the prompt

  Used to determine if a new line should be sent before sending out
  new text.
  """

  defstruct [:text]
end
