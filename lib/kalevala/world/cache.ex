defmodule Kalevala.World.Cache do
  @moduledoc """
  GenServer for caching in game resources

  ## Example

  ```
  defmodule Kantele.World.Items do
    use Kalevala.World.Cache
  end
  ```

  ```
  iex> Kalevala.World.Items.put("sammatti:sword", %Item{})
  iex> Kalevala.World.Items.get("sammatti:sword")
  %Item{}
  ```
  """

  use GenServer

  defstruct [:ets_key]

  defmacro __using__(_opts) do
    quote do
      def put(key, value) do
        Kalevala.World.Cache.put(__MODULE__, key, value)
      end

      def get(key) do
        Kalevala.World.Cache.get(__MODULE__, key)
      end

      def get!(key) do
        case get(key) do
          {:ok, value} ->
            value

          {:error, :not_found} ->
            raise "Could not find key #{key} in cache #{__MODULE__}"
        end
      end
    end
  end

  def start_link(opts) do
    opts = Enum.into(opts, %{})
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def put(name, key, value) do
    GenServer.call(name, {:set, key, value})
  end

  def get(name, key) do
    case :ets.lookup(name, key) do
      [{^key, value}] ->
        {:ok, value}

      _ ->
        {:error, :not_found}
    end
  end

  def init(config) do
    state = %__MODULE__{
      ets_key: config.name
    }

    :ets.new(state.ets_key, [:set, :protected, :named_table])

    {:ok, state}
  end

  def handle_call({:set, key, value}, _from, state) do
    :ets.insert(state.ets_key, {key, value})

    {:reply, :ok, state}
  end
end
