defmodule Kalevala.Communication.Channel do
  @moduledoc """
  A GenServer to handle channel communication
  """

  use GenServer

  alias Kalevala.Communication.Cache
  alias Kalevala.Event
  alias Kalevala.Event.Message

  @typedoc """
  Config is saved and stored in the GenServer, passed in for each callback
  """
  @type config() :: map()

  @typedoc """
  Options are for each subscribe/publish request

  This may contain information like charcater data
  """
  @type options() :: map()

  @typedoc """
  The "topic" in the channel pub/sub

  This might be a simple global channel name or something specific to rooms,
  maybe `rooms:id`.
  """
  @type channel_name() :: String.t()

  @doc """
  Called during initialization

  You can change any of the config you wish on start of the gen server
  """
  @callback init(config()) :: config()

  @doc """
  Called before a pid is allowed to subscribe to a channel
  """
  @callback subscribe_request(channel_name(), options(), config()) :: :ok

  @doc """
  Called before a pid is allowed to unsubscribe to a channel
  """
  @callback unsubscribe_request(channel_name(), options(), config()) :: :ok

  @doc """
  Called before a message is allowed to publish on the channel
  """
  @callback publish_request(channel_name(), Event.message(), options(), config()) :: :ok

  defstruct [:callback_module, :channel_name, :config, :subscriber_ets_key]

  defmacro __using__(_opts) do
    quote do
      @behaviour Kalevala.Communication.Channel

      @impl true
      def init(config), do: config

      @impl true
      def subscribe_request(_channel_name, _options, _config), do: :ok

      @impl true
      def unsubscribe_request(_channel_name, _options, _config), do: :ok

      @impl true
      def publish_request(_channel_name, _message, _options, _config), do: :ok

      defoverridable init: 1, subscribe_request: 3, unsubscribe_request: 3, publish_request: 4
    end
  end

  @doc """
  Publish a new message
  """
  def publish(pid, message, options) do
    GenServer.call(pid, {:publish, message, options})
  end

  @doc """
  Subscribe to a new channel

  Allows for the callback_module to reject subscription
  """
  def subscribe(pid, channel_name, subscriber_pid, options) do
    GenServer.call(pid, {:subscribe, channel_name, subscriber_pid, options})
  end

  @doc """
  Unsubscribe to a new channel

  Allows for the callback_module to reject unsubscription
  """
  def unsubscribe(pid, channel_name, subscriber_pid, options) do
    GenServer.call(pid, {:unsubscribe, channel_name, subscriber_pid, options})
  end

  @doc false
  def start_link(opts, genserver_opts \\ []) do
    GenServer.start_link(__MODULE__, opts, genserver_opts)
  end

  @impl true
  def init({channel_name, callback_module, options}) do
    state = %__MODULE__{
      callback_module: callback_module,
      channel_name: channel_name,
      config: callback_module.init(options[:config]),
      subscriber_ets_key: options[:subscriber_ets_key]
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:publish, event = %Event{topic: Message}, options}, _from, state) do
    case state.callback_module.publish_request(state.channel_name, event, options, state.config) do
      :ok ->
        subscribers = Cache.subscribers(state.subscriber_ets_key, state.channel_name)

        Enum.each(subscribers, fn {_, subscriber_pid, _} ->
          send(subscriber_pid, event)
        end)

        {:reply, :ok, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:subscribe, channel_name, subscriber_pid, options}, _from, state) do
    case state.callback_module.subscribe_request(channel_name, options, state.config) do
      :ok ->
        Process.monitor(subscriber_pid)
        :ets.insert(state.subscriber_ets_key, {channel_name, subscriber_pid, options})
        {:reply, :ok, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:unsubscribe, channel_name, subscriber_pid, options}, _from, state) do
    case state.callback_module.unsubscribe_request(channel_name, options, state.config) do
      :ok ->
        :ets.match_delete(state.subscriber_ets_key, {channel_name, subscriber_pid, :_})
        {:reply, :ok, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, subscriber_pid, _reason}, state) do
    :ets.match_delete(state.subscriber_ets_key, {state.channel_name, subscriber_pid, :_})
    {:noreply, state}
  end
end
