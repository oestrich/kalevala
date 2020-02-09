defmodule Kalevala.Character do
  @moduledoc """
  Character struct

  Common data that all characters will have
  """

  defstruct [:id, :room_id, :name, :status, :description, meta: %{}]
end
