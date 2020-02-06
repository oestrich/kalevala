defmodule Kalevala.Event do
  @moduledoc """
  An internal event
  """

  @type t() :: %__MODULE__{}

  defstruct [:topic, :data]
end
