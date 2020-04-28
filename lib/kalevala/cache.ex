defmodule Kalevala.Cache do
  @moduledoc """
  GenServer for caching in game resources

  ## Example

  ```
  defmodule Kantele.World.Items do
    use Kalevala.Cache
  end
  ```

  ```
  iex> Kalevala.Items.put("sammatti:sword", %Item{})
  iex> Kalevala.Items.get("sammatti:sword")
  %Item{}
  ```
  """

  use GenServer

  @type t() :: %__MODULE__{}

  @doc """
  Called after the cache is booted

  A chance to warm the cache before accepting outside updates.
  """
  @callback initialize(t()) :: :ok

  defstruct [:ets_key, :callback_module]

  defmacro __using__(_opts) do
    quote do
      @behaviour Kalevala.Cache

      @doc false
      def child_spec(opts) do
        %{
          id: Kalevala.Cache,
          start: {__MODULE__, :start_link, [opts]}
        }
      end

      @doc false
      def start_link(opts) do
        opts = Keyword.merge([callback_module: __MODULE__], opts)
        Kalevala.Cache.start_link(opts)
      end

      @impl true
      def initialize(_state), do: :ok

      @doc """
      Put a value in the cache
      """
      def put(key, value) do
        Kalevala.Cache.put(__MODULE__, key, value)
      end

      @doc """
      Get a value from the cache
      """
      def get(key) do
        Kalevala.Cache.get(__MODULE__, key)
      end

      @doc """
      Get a value from the cache

      Unwraps the tagged tuple, returns the direct value. Raises an error
      if the value is not already in the cache.
      """
      def get!(key) do
        case get(key) do
          {:ok, value} ->
            value

          {:error, :not_found} ->
            raise "Could not find key #{key} in cache #{__MODULE__}"
        end
      end

      defoverridable initialize: 1
    end
  end

  @doc false
  def start_link(opts) do
    opts = Enum.into(opts, %{})
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @doc """
  Put a new value into the cache
  """
  def put(name, key, value) do
    GenServer.call(name, {:set, key, value})
  end

  @doc """
  Get a value out of the cache
  """
  def get(name, key) do
    case :ets.lookup(name, key) do
      [{^key, value}] ->
        {:ok, value}

      _ ->
        {:error, :not_found}
    end
  end

  @impl true
  def init(config) do
    state = %__MODULE__{
      ets_key: config.name,
      callback_module: config.callback_module
    }

    :ets.new(state.ets_key, [:set, :protected, :named_table])

    {:ok, state, {:continue, :initialize}}
  end

  @impl true
  def handle_continue(:initialize, state) do
    state.callback_module.initialize(state)

    {:noreply, state}
  end

  @impl true
  def handle_call({:set, key, value}, _from, state) do
    _put(state, key, value)

    {:reply, :ok, state}
  end

  @doc false
  def _put(state, key, value) do
    :ets.insert(state.ets_key, {key, value})
  end
end
