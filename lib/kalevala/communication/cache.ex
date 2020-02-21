defmodule Kalevala.Communication.Cache do
  @moduledoc """
  A local cache server for communication

  Tracks which channels are registered to which PID and which pids
  are subscribed to which channel.
  """

  use GenServer

  alias Kalevala.Communication.Channels

  defstruct [:cache_name, :channels_name, :channel_ets_key, :subscriber_ets_key]

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:config], opts)
  end

  @doc """
  Register a new channel
  """
  def register(pid, channel_name, callback_module, options) do
    GenServer.call(pid, {:register, {channel_name, callback_module, options}})
  end

  @doc """
  Get a list of all subscribers on a channel
  """
  def subscribers(subscriber_ets_key, channel_name) do
    :ets.match_object(subscriber_ets_key, {channel_name, :"$1", :_})
  end

  @impl true
  def init(config) do
    state = %__MODULE__{
      cache_name: config[:cache_name],
      channels_name: config[:channels_name],
      channel_ets_key: config[:channel_ets_key],
      subscriber_ets_key: config[:subscriber_ets_key]
    }

    :ets.new(state.channel_ets_key, [:set, :protected, :named_table])
    :ets.new(state.subscriber_ets_key, [:bag, :public, :named_table])

    {:ok, state, {:continue, {:register, config[:channels]}}}
  end

  @impl true
  def handle_continue({:register, channels}, state) when is_list(channels) do
    Enum.each(channels, fn {channel_name, callback_module, options} ->
      register_channel(state, channel_name, callback_module, options)
    end)

    {:noreply, state}
  end

  @impl true
  def handle_call({:register, {channel_name, callback_module, config}}, _from, state) do
    case :ets.lookup(state.channel_ets_key, channel_name) do
      [{^channel_name, _}] ->
        {:reply, {:error, :already_registered}, state}

      _ ->
        register_channel(state, channel_name, callback_module, config)
        {:reply, :ok, state}
    end
  end

  defp register_channel(state, channel_name, callback_module, config) do
    options = [subscriber_ets_key: state.subscriber_ets_key, config: config]
    {:ok, pid} = Channels.start_child(state.channels_name, channel_name, callback_module, options)
    :ets.insert(state.channel_ets_key, {channel_name, pid})
  end
end
