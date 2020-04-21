defmodule Kalevala.World.Item do
  @moduledoc """
  Item struct

  Common data that all items will have
  """

  defstruct [:id, :name, :description, :callback_module, meta: %{}]

  @doc """
  Reduce the size of the meta map before sending in an event
  """
  @callback trim_meta(meta :: map()) :: map()
end

defmodule Kalevala.World.Item.Instance do
  @moduledoc """
  Item instance struct

  A specific instance of an item in the world
  """

  defstruct [:id, :item_id, :created_at, :callback_module, meta: %{}]

  @doc """
  Reduce the size of the meta map before sending in an event
  """
  @callback trim_meta(meta :: map()) :: map()
end
