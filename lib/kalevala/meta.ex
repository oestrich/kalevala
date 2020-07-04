defprotocol Kalevala.Meta do
  @moduledoc """
  Protocol for dealing with extra metadata on an instance from Kalevala
  """

  @doc """
  Trim metadata down to fields that should be publicly accessible

  These will be included when being sent around in events
  """
  def trim(meta)
end

defimpl Kalevala.Meta, for: Map do
  def trim(_meta), do: %{}
end
