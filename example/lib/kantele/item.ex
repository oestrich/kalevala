defmodule Kantele.Item do
  @moduledoc """
  Item struct

  Common data that all items will have
  """

  defstruct [:id, :room_id, :name, :description, meta: %{}]

  @doc """
  Reduce the size of the meta map before sending in an event
  """
  @callback trim_meta(meta :: map()) :: map()
end
