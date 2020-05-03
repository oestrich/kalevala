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

  @doc """
  Generate a random ID
  """
  def generate_id() do
    bytes =
      Enum.reduce(1..4, <<>>, fn _, bytes ->
        bytes <> <<Enum.random(0..255)>>
      end)

    Base.encode16(bytes, case: :lower)
  end
end
