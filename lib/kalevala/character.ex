defmodule Kalevala.Character do
  @moduledoc """
  Character struct

  Common data that all characters will have
  """

  defstruct [
    :brain,
    :description,
    :id,
    :name,
    :pid,
    :room_id,
    :status,
    inventory: [],
    meta: %{}
  ]

  defimpl Jason.Encoder do
    def encode(character, opts) do
      meta = Kalevala.Meta.trim(character.meta)

      character =
        character
        |> Map.take([:description, :id, :name, :status])
        |> Map.put(:meta, meta)

      Jason.Encode.map(character, opts)
    end
  end

  @doc """
  Check if a keyword matches the character
  """
  def matches?(character, keyword) do
    character.id == keyword ||
      String.downcase(character.name) == String.downcase(keyword)
  end

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
