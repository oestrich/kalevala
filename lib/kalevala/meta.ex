defprotocol Kalevala.Meta.Trim do
  @moduledoc """
  Protocol for dealing with extra metadata on an instance from Kalevala
  """

  @doc """
  Trim metadata down to fields that should be publicly accessible

  These will be included when being sent around in events
  """
  def trim(meta)
end

defprotocol Kalevala.Meta.Access do
  def get(map, key)

  def put(map, key, value)
end

defimpl Kalevala.Meta.Trim, for: Map do
  def trim(_meta), do: %{}
end

defimpl Kalevala.Meta.Access, for: Map do
  def get(map, key), do: Map.get(map, key)

  def put(map, key, value), do: Map.get(map, key, value)
end

defmodule Kalevala.Meta.Trimmed do
  @moduledoc """
  Struct to tag trimmed metadata as already trimmed
  """

  defstruct []

  defimpl Kalevala.Meta.Trim do
    def trim(meta), do: meta
  end

  defimpl Kalevala.Meta.Access do
    def get(meta, key), do: Map.get(meta, key)

    def put(_meta, _key, _value), do: raise("Can't alter trimmed meta!")
  end

  defimpl Jason.Encoder do
    def encode(meta, opts) do
      Jason.Encode.map(Map.delete(meta, :__struct__), opts)
    end
  end
end

defmodule Kalevala.Meta do
  @moduledoc """
  Trim extra metadata on an instance metadata
  """

  @doc """
  Trim extra metadata on an instance metadata
  """
  def trim(meta) do
    meta
    |> Kalevala.Meta.Trim.trim()
    |> Map.put(:__struct__, Kalevala.Meta.Trimmed)
  end

  def get(meta, key), do: Kalevala.Meta.Access.get(meta, key)

  def put(meta, key, value), do: Kalevala.Meta.Access.put(meta, key, value)
end
