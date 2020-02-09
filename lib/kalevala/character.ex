defmodule Kalevala.Character do
  @moduledoc """
  Character struct

  Common data that all characters will have
  """

  defstruct [:id, :pid, :room_id, :name, :status, :description, meta: %{}]

  @doc """
  Reduce the size of the meta map before sending in an event
  """
  @callback trim_meta(meta :: map()) :: map()
end
