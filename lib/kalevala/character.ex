defmodule Kalevala.Character do
  @moduledoc """
  Character struct

  Common data that all characters will have
  """

  defstruct [:id, :name, :status, :description, meta: %{}]
end
