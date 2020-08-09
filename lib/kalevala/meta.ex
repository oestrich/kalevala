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

defimpl Kalevala.Meta.Trim, for: Map do
  def trim(_meta), do: %{}
end

defmodule Kalevala.Meta.Trimmed do
  @moduledoc """
  Struct to tag trimmed metadata as already trimmed
  """

  defstruct []

  defimpl Kalevala.Meta.Trim do
    def trim(meta), do: meta
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
end
