defmodule Kalevala.World.Item do
  @moduledoc """
  Item struct

  Common data that all items will have
  """

  defstruct [:id, :name, :description, :callback_module, meta: %{}]

  @type t() :: %__MODULE__{}

  @doc """
  Reduce the size of the meta map before sending in an event
  """
  @callback trim_meta(meta :: map()) :: map()

  @doc """
  Match a string against the item
  """
  @callback matches?(item :: t(), keyword :: String.t()) :: boolean()

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)

      @impl true
      def matches?(item, keyword) do
        String.downcase(item.name) == String.downcase(keyword)
      end

      defoverridable matches?: 2
    end
  end
end

defmodule Kalevala.World.Item.ItemNotLoaded do
  @moduledoc """
  An empty struct for item instances to include by default

  To know that the item is _not_ loaded and you should load it
  """

  defstruct []
end

defmodule Kalevala.World.Item.Instance do
  @moduledoc """
  Item instance struct

  A specific instance of an item in the world
  """

  alias Kalevala.World.Item.ItemNotLoaded

  defstruct [:id, :item_id, :created_at, :callback_module, item: %ItemNotLoaded{}, meta: %{}]

  @type t() :: %__MODULE__{}

  @doc """
  Reduce the size of the meta map before sending in an event
  """
  @callback trim_meta(meta :: map()) :: map()

  @doc """
  Generate a random instance ID
  """
  def generate_id() do
    bytes =
      Enum.reduce(1..8, <<>>, fn _, bytes ->
        bytes <> <<Enum.random(0..255)>>
      end)

    Base.encode16(bytes, case: :lower)
  end
end
