defmodule Kantele.World.Items do
  @moduledoc false

  use Kalevala.World.Cache
end

defmodule Kantele.World.Item do
  @moduledoc """
  Local callbacks for `Kalevala.World.Item`
  """

  @behaviour Kalevala.World.Item

  @impl true
  def trim_meta(_meta), do: %{}
end

defmodule Kantele.World.Item.Instance do
  @moduledoc """
  Local callbacks for `Kalevala.World.Item.Instance`
  """

  @behaviour Kalevala.World.Item.Instance

  @impl true
  def trim_meta(_meta), do: %{}
end
