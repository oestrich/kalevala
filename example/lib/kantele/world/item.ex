defmodule Kantele.World.Items do
  @moduledoc false

  use Kalevala.Cache
end

defmodule Kantele.World.Item do
  @moduledoc """
  Local callbacks for `Kalevala.World.Item`
  """

  use Kalevala.World.Item
end

defmodule Kantele.World.Item.Meta do
  @moduledoc """
  Item metadata, implements `Kalevala.Meta`
  """

  defstruct []

  defimpl Kalevala.Meta do
    def trim(_meta), do: %{}
  end
end
