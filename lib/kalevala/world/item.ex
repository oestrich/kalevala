defmodule Kalevala.World.Item do
  @moduledoc """
  Item struct

  Common data that all items will have
  """

  defstruct [:id, :name, :description, :callback_module, meta: %{}]

  defimpl Jason.Encoder do
    alias Kalevala.Meta

    def encode(item, opts) do
      json = Map.take(item, [:id, :name, :description])
      json = Map.merge(json, %{meta: Meta.trim(item.meta)})
      Jason.Encode.map(json, opts)
    end
  end

  @type t() :: %__MODULE__{}

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

  @derive Jason.Encoder
  defstruct []
end

defmodule Kalevala.World.Item.Instance do
  @moduledoc """
  Item instance struct

  A specific instance of an item in the world
  """

  alias Kalevala.World.Item.ItemNotLoaded

  @derive {Jason.Encoder, only: [:id, :item_id, :item, :created_at]}
  defstruct [:id, :item_id, :created_at, item: %ItemNotLoaded{}, meta: %{}]

  @type t() :: %__MODULE__{}

  @doc """
  Generate a random instance ID
  """
  def generate_id() do
    bytes =
      Enum.reduce(1..4, <<>>, fn _, bytes ->
        bytes <> <<Enum.random(0..255)>>
      end)

    Base.encode16(bytes, case: :lower)
  end
end
