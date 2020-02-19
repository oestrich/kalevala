defmodule Kalevala.Communication.Message do
  @moduledoc """
  Struct for sending a message
  """

  @type t() :: %__MODULE__{}

  defstruct [:channel_name, :character, :text, emote: false, meta: %{}]
end

defmodule Kalevala.Communication do
  @moduledoc """
  Handle communication for the game

  Register global channels, room channels, character channels, etc.
  """

  require Logger

  alias Kalevala.Communication.Cache
  alias Kalevala.Communication.Channel
  alias Kalevala.Communication.Message

  defmacro __using__(_opts) do
    quote do
      use Supervisor

      alias Kalevala.Communication.Cache
      alias Kalevala.Communication.Channel
      alias Kalevala.Communication.Channels

      @behaviour Kalevala.Communication

      def start_link(opts, genserver_opts \\ []) do
        Supervisor.start_link(__MODULE__, opts, genserver_opts)
      end

      @doc false
      def config(config_overrides) do
        default_config = [
          channels_name: __MODULE__.Channels,
          cache_name: __MODULE__.Cache,
          channel_ets_key: __MODULE__.Channels,
          subscriber_ets_key: __MODULE__.Subscribers
        ]

        Keyword.merge(default_config, config_overrides)
      end

      @impl true
      def init(config_overrides) do
        config = config(config_overrides)

        children = [
          {Channels, [name: config[:channels_name], config: config]},
          {Cache, [name: config[:cache_name], config: [{:channels, initial_channels()} | config]]}
        ]

        Supervisor.init(children, strategy: :one_for_one)
      end

      @impl true
      def initial_channels(), do: []

      def register(channel_name, callback_module, options, config_overrides \\ []) do
        cache_name = config(config_overrides)[:cache_name]
        Kalevala.Communication.register(cache_name, channel_name, callback_module, options)
      end

      @doc """
      Subscribe the current pid to the channel
      """
      def subscribe(channel_name, options, config_overrides \\ []) do
        channel_ets_key = config(config_overrides)[:channel_ets_key]
        Kalevala.Communication.subscribe(channel_ets_key, channel_name, self(), options)
      end

      @doc """
      Unsubscribe the current pid to the channel
      """
      def unsubscribe(channel_name, options, config_overrides \\ []) do
        channel_ets_key = config(config_overrides)[:channel_ets_key]
        Kalevala.Communication.unsubscribe(channel_ets_key, channel_name, self(), options)
      end

      def subscribers(channel_name, config_overrides \\ []) do
        subscriber_ets_key = config(config_overrides)[:subscriber_ets_key]
        Cache.subscribers(subscriber_ets_key, channel_name)
      end

      def publish(channel_name, message, options, config_overrides \\ []) do
        channel_ets_key = config(config_overrides)[:channel_ets_key]
        Kalevala.Communication.publish(channel_ets_key, channel_name, message, options)
      end

      defoverridable initial_channels: 0
    end
  end

  @callback initial_channels() :: []

  @doc """
  Register a new channel with a callback
  """
  def register(pid, channel_name, callback_module, options) do
    Cache.register(pid, channel_name, callback_module, options)
  end

  @doc """
  Subscribe the current PID to a channel
  """
  def subscribe(channel_ets_key, channel_name, subscriber_pid, options) do
    case :ets.lookup(channel_ets_key, channel_name) do
      [{^channel_name, pid}] ->
        Channel.subscribe(pid, channel_name, subscriber_pid, options)

      _ ->
        :error
    end
  end

  @doc """
  Unsubscribe the current PID to a channel
  """
  def unsubscribe(channel_ets_key, channel_name, subscriber_pid, options) do
    case :ets.lookup(channel_ets_key, channel_name) do
      [{^channel_name, pid}] ->
        Channel.unsubscribe(pid, channel_name, subscriber_pid, options)

      _ ->
        :error
    end
  end

  @doc """
  Publish a message on a channel
  """
  def publish(channel_ets_key, channel_name, message = %Message{}, options) do
    case :ets.lookup(channel_ets_key, channel_name) do
      [{^channel_name, pid}] ->
        Channel.publish(pid, message, options)

      _ ->
        :error
    end
  end

  def publish(_channel_ets_key, channel_name, message, _options) do
    Logger.warn("""
    Trying to publish #{inspect(message)} on `#{channel_name}`.
    Only message structs allowed.
    """)

    :error
  end
end
