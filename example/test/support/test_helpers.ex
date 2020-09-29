defmodule Kantele.TestHelpers do
  @moduledoc """
  Helpers for generating structs in tests
  """

  @doc """
  Generate a character struct
  """
  def generate_character(name, brain \\ nil) do
    %Kalevala.Character{
      id: Kalevala.Character.generate_id(),
      name: name,
      pid: self(),
      brain: brain,
      room_id: "room-id"
    }
  end
end
