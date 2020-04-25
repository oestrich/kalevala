defmodule Kalevala.Event.ItemDrop.Request do
  @moduledoc """
  Request to pick up an item from the room
  """

  defstruct [:item_instance]
end

defmodule Kalevala.Event.ItemDrop.Abort do
  @moduledoc """
  Request to pick up an item from the room
  """

  defstruct [:from, :item_instance, :reason]
end

defmodule Kalevala.Event.ItemDrop.Commit do
  @moduledoc """
  Request to pick up an item from the room
  """

  defstruct [:from, :item_instance]
end

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
