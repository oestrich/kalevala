defmodule Kalevala.Event.ItemPickUp.Request do
  @moduledoc """
  Request to pick up an item from the room
  """

  defstruct [:item_name]
end

defmodule Kalevala.Event.ItemPickUp.Abort do
  @moduledoc """
  Request to pick up an item from the room
  """

  defstruct [:from, :item_name, :reason]
end

defmodule Kalevala.Event.ItemPickUp.Commit do
  @moduledoc """
  Request to pick up an item from the room
  """

  defstruct [:from, :item_name, :item_instance]
end
