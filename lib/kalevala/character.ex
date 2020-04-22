defmodule Kalevala.Character do
  @moduledoc """
  Character struct

  Common data that all characters will have
  """

  defstruct [
    :description,
    :id,
    :name,
    :pid,
    :room_id,
    :status,
    inventory: [],
    meta: %{}
  ]

  @doc """
  Reduce the size of the meta map before sending in an event
  """
  @callback trim_meta(meta :: map()) :: map()
end
