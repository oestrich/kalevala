defmodule Kalevala.CommunicationTest do
  use ExUnit.Case

  alias Kalevala.Communication.Message

  defmodule TestCommunication do
    use Kalevala.Communication
  end

  defmodule BroadcastChannel do
    use Kalevala.Communication.Channel
  end

  defmodule RestrictedChannel do
    use Kalevala.Communication.Channel

    @impl true
    def subscribe_request(_channel_name, [let_me_in: true], _config), do: :ok

    def subscribe_request(_channel_name, _options, _config), do: {:error, "You're not allowed in"}

    @impl true
    def unsubscribe_request(_channel_name, [let_me_out: true], _config), do: :ok

    def unsubscribe_request(_channel_name, _options, _config),
      do: {:error, "You're not allowed to leave"}

    @impl true
    def publish_request(_channel_name, _message, [let_me_in: true], _config), do: :ok

    def publish_request(_channel_name, _message, _options, _config),
      do: {:error, "You're not allowed in"}
  end

  defmodule Subscriber do
    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, [], [])
    end

    def subscribe(pid, channel, config_overrides) do
      GenServer.call(pid, {:subscribe, channel, config_overrides})
    end

    def init(_) do
      {:ok, %{}}
    end

    def handle_call({:subscribe, channel, config_overrides}, _from, state) do
      :ok = TestCommunication.subscribe(channel, [], config_overrides)
      {:reply, :ok, state}
    end
  end

  describe "registering new channels" do
    test "spins up the channel process" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", BroadcastChannel, [], config_overrides)
    end

    test "allows you to register a channel name _once_" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", BroadcastChannel, [], config_overrides)
      :error = TestCommunication.register("general", BroadcastChannel, [], config_overrides)
    end
  end

  describe "subscribing" do
    test "subscribes the current process to the channel" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", BroadcastChannel, [], config_overrides)

      :ok = TestCommunication.subscribe("general", [], config_overrides)

      assert_subscribers("general", [self()], config_overrides)
    end

    test "subscribing keeps the same subscription" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", BroadcastChannel, [], config_overrides)

      :ok = TestCommunication.subscribe("general", [], config_overrides)
      :ok = TestCommunication.subscribe("general", [], config_overrides)

      assert_subscribers("general", [self()], config_overrides)
    end

    test "allows for a callback to block the subscription" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", RestrictedChannel, [], config_overrides)

      {:error, reason} = TestCommunication.subscribe("general", [], config_overrides)

      assert reason == "You're not allowed in"
      assert_subscribers("general", [], config_overrides)

      :ok = TestCommunication.subscribe("general", [let_me_in: true], config_overrides)
      assert_subscribers("general", [self()], config_overrides)
    end

    test "tracks subscribers when their process clears out" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", BroadcastChannel, [], config_overrides)

      {:ok, pid} = Subscriber.start_link()
      :ok = Subscriber.subscribe(pid, "general", config_overrides)
      assert_subscribers("general", [pid], config_overrides)

      GenServer.stop(pid, :normal)

      # lock for the DOWN message to the channel process
      block_channel("general", config_overrides)

      assert_subscribers("general", [], config_overrides)
    end
  end

  describe "unsubscribing" do
    test "unsubscribes the current process to the channel" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", BroadcastChannel, [], config_overrides)
      :ok = TestCommunication.subscribe("general", [], config_overrides)

      :ok = TestCommunication.unsubscribe("general", [], config_overrides)

      assert_subscribers("general", [], config_overrides)
    end

    test "allows for a callback to block the unsubscription" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", RestrictedChannel, [], config_overrides)
      :ok = TestCommunication.subscribe("general", [let_me_in: true], config_overrides)

      {:error, reason} = TestCommunication.unsubscribe("general", [], config_overrides)
      assert reason == "You're not allowed to leave"
      assert_subscribers("general", [self()], config_overrides)

      :ok = TestCommunication.unsubscribe("general", [let_me_out: true], config_overrides)
      assert_subscribers("general", [], config_overrides)
    end
  end

  describe "publishing" do
    test "publishing to the channel and broadcasts to subscribers" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", BroadcastChannel, [], config_overrides)
      :ok = TestCommunication.subscribe("general", [], config_overrides)

      :ok = TestCommunication.publish("general", %Message{}, [], config_overrides)

      assert_receive %Message{}
    end

    test "allows for a callback to block the publish" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", RestrictedChannel, [], config_overrides)
      :ok = TestCommunication.subscribe("general", [let_me_in: true], config_overrides)

      {:error, reason} = TestCommunication.publish("general", %Message{}, [], config_overrides)
      assert reason == "You're not allowed in"

      :ok = TestCommunication.publish("general", %Message{}, [let_me_in: true], config_overrides)
      assert_receive %Message{}
    end

    test "blocks publishing non message structs" do
      config_overrides = start_link()

      :ok = TestCommunication.register("general", BroadcastChannel, [], config_overrides)
      :ok = TestCommunication.subscribe("general", [], config_overrides)

      :error = TestCommunication.publish("general", "message", [], config_overrides)
    end
  end

  defp start_link() do
    config_overrides = generate_config_overrides()
    {:ok, _pid} = TestCommunication.start_link(config_overrides)
    config_overrides
  end

  defp generate_config_overrides() do
    key = Base.url_encode64(:crypto.strong_rand_bytes(8))

    [
      channels_name: :"#{key}_channels",
      cache_name: :"#{key}_cache",
      channel_ets_key: :"#{key}_channels",
      subscriber_ets_key: :"#{key}_subscribers"
    ]
  end

  def assert_subscribers(channel, pids, config_overrides) do
    subscribers = TestCommunication.subscribers(channel, config_overrides)

    subscriber_pids =
      Enum.map(subscribers, fn {^channel, pid, _options} ->
        pid
      end)

    assert subscriber_pids == pids, "Subscriber PIDs don't match"
  end

  @doc """
  Blocks a channel by fetching it's state

  Let's messages that are processed async catch up before asserting
  """
  def block_channel(channel_name, config_overrides) do
    [{^channel_name, pid}] = :ets.lookup(config_overrides[:channel_ets_key], channel_name)
    :sys.get_state(pid)
  end
end
