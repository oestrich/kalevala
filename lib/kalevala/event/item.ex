defmodule Kalevala.Event.ItemDrop do
  @moduledoc """
  Events to drop an item in a room

  In order to drop an item, send an `ItemDrop.Request` event with the
  item instance. The room will call the `item_request_drop` callback
  on the room module.

  Depending on the response, an `Abort` or `Commit` event will be sent.
  """
end

defmodule Kalevala.Event.ItemDrop.Request do
  @moduledoc """
  Request to pick up an item from the room
  """

  defstruct [:item_instance]
end

defmodule Kalevala.Event.ItemDrop.Abort do
  @moduledoc """
  The request to drop an item was aborted by the room

  The item should be kept in the character's inventory.
  """

  defstruct [:from, :item_instance, :reason]
end

defmodule Kalevala.Event.ItemDrop.Commit do
  @moduledoc """
  The request to drop an item was committed by the room

  The item should be removed from the character's inventory. The item is
  already in the room.
  """

  defstruct [:from, :item_instance]
end

defmodule Kalevala.Event.ItemPickUp do
  @moduledoc """
  Events to pick up item in a room

  In order to pick up an item, send an `ItemPickUp.Request` event with the
  item name. The room will try to find the matching item(s) based on the
  `matches?/2` callback on the item after loading them from instances in
  the room.

  After finding a matching item, the `item_request_pickup` callback is
  called on the room module.

  Depending on the response, an `Abort` or `Commit` event will be sent.
  """
end

defmodule Kalevala.Event.ItemPickUp.Request do
  @moduledoc """
  Request to pick up an item from the room
  """

  defstruct [:item_name]
end

defmodule Kalevala.Event.ItemPickUp.Abort do
  @moduledoc """
  The request to pick up an item was aborted by the room

  The item cannot be added to the character's room.
  """

  defstruct [:from, :item_instance, :item_name, :reason]
end

defmodule Kalevala.Event.ItemPickUp.Commit do
  @moduledoc """
  The request to pick up an item was committed by the room

  The item should be added to the character's inventory. The item instance
  was is longer in the room.
  """

  defstruct [:from, :item_name, :item_instance]
end
