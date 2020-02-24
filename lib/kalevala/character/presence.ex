defmodule Kalevala.Character.Presence do
  @moduledoc """
  Track the presence of online characters
  """

  use GenServer

  alias Kalevala.Character.Presence.Implementation

  @doc """
  Notify the callback module that a character is online
  """
  @callback online(Character.t()) :: :ok

  @doc """
  Notify the callback module that a character is offline
  """
  @callback offline(Character.t()) :: :ok

  defstruct [:callback_module, :ets_key]

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)

      def characters() do
        unquote(__MODULE__).characters(__MODULE__)
      end

      def track(character), do: unquote(__MODULE__).track(__MODULE__, character)

      def child_spec(_opts) do
        unquote(__MODULE__).child_spec(callback_module: __MODULE__, name: __MODULE__)
      end

      @doc false
      def start_link(_opts) do
        unquote(__MODULE__).start_link(callback_module: __MODULE__, name: __MODULE__)
      end

      @impl true
      def online(_character), do: :ok

      @impl true
      def offline(_character), do: :ok

      defoverridable online: 1, offline: 1
    end
  end

  @doc """
  Start tracking a character (and it's actor process)
  """
  def track(pid, character) do
    GenServer.call(pid, {:track, character})
  end

  @doc """
  Load all online characters
  """
  def characters(ets_key) do
    ets_key
    |> Implementation.keys()
    |> Enum.map(&lookup(ets_key, &1))
    |> Enum.reject(&match?(:error, &1))
    |> Enum.map(fn {:ok, character} ->
      character
    end)
  end

  @doc false
  def start_link(opts) do
    opts = Enum.into(opts, %{})
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(config) do
    state = %__MODULE__{
      ets_key: config.name,
      callback_module: config.callback_module
    }

    :ets.new(state.ets_key, [:set, :protected, :named_table])

    {:ok, state}
  end

  def handle_call({:track, character}, _from, state) do
    state.callback_module.online(character)
    :ets.insert(state.ets_key, {character.pid, character})
    Process.monitor(character.pid)
    {:reply, :ok, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    with {:ok, character} <- lookup(state.ets_key, pid) do
      state.callback_module.offline(character)
    end

    :ets.delete(state.ets_key, pid)

    {:noreply, state}
  end

  defp lookup(ets_key, pid) do
    case :ets.lookup(ets_key, pid) do
      [{^pid, character}] ->
        {:ok, character}

      _ ->
        :error
    end
  end

  defmodule Implementation do
    @moduledoc false

    @doc false
    def keys(ets_key) do
      key = :ets.first(ets_key)
      keys(ets_key, key, [key])
    end

    def keys(_ets_key, :"$end_of_table", [:"$end_of_table" | accumulator]), do: accumulator

    def keys(ets_key, current_key, accumulator) do
      next_key = :ets.next(ets_key, current_key)
      keys(ets_key, next_key, [next_key | accumulator])
    end
  end
end
