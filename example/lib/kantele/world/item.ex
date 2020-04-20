defmodule Kantele.World.Item do
  @behaviour Kalevala.World.Item

  @impl true
  def trim_meta(_meta), do: %{}
end
