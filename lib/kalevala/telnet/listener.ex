defmodule Kalevala.Telnet.Listener do
  @moduledoc """
  Process that starts the `ranch` listener
  """

  use GenServer

  require Logger

  alias Kalevala.Telnet.Protocol

  def start_link(opts \\ []) do
    opts = Enum.into(opts, %{})
    GenServer.start_link(__MODULE__, opts, Map.get(opts, :otp, []))
  end

  def init(config) do
    {:ok, %{config: config}, {:continue, :listen_tcp}}
  end

  def handle_continue(:listen_tcp, state) do
    telnet_config = Map.get(state.config, :telnet, [])
    port = Keyword.get(telnet_config, :port, 4444)

    opts = %{
      socket_opts: [{:port, port}],
      max_connections: 102_400
    }

    actor_options = Map.get(state.config, :actor, [])

    case :ranch.start_listener({__MODULE__, :tcp}, :ranch_tcp, opts, Protocol, actor_options) do
      {:ok, listener} ->
        set_listener(state, listener)

      {:error, {:already_started, listener}} ->
        set_listener(state, listener)
    end
  end

  def handle_continue(:listen_tls, state) do
    telnet_config = Map.get(state.config, :tls, [])
    port = Keyword.get(telnet_config, :port, 4444)

    opts = %{
      socket_opts: [
        {:port, port},
        {:keyfile, keyfile(state.config.tls)},
        {:certfile, certfile(state.config.tls)}
      ],
      max_connections: 4096
    }

    actor_options = Map.get(state.config, :actor, [])

    case :ranch.start_listener({__MODULE__, :tls}, :ranch_ssl, opts, Protocol, actor_options) do
      {:ok, listener} ->
        set_tls_listener(state, listener)

      {:error, {:already_started, listener}} ->
        set_tls_listener(state, listener)
    end
  end

  defp keyfile(config) do
    case config[:keyfile] do
      nil ->
        raise "The `keyfile` config must be set if tls is true!"

      keyfile ->
        keyfile
    end
  end

  defp certfile(config) do
    case config[:certfile] do
      nil ->
        raise "The `certfile` config must be set if tls is true!"

      certfile ->
        certfile
    end
  end

  defp set_listener(state, listener) do
    Logger.info("Telnet Listener Started")

    state = Map.put(state, :listener, listener)

    tls_config = Map.get(state.config, :tls)

    case is_nil(tls_config) || Enum.empty?(tls_config) do
      true ->
        {:noreply, state}

      false ->
        {:noreply, state, {:continue, :listen_tls}}
    end
  end

  defp set_tls_listener(state, listener) do
    Logger.info("TLS Listener Started")
    state = Map.put(state, :tls_listener, listener)
    {:noreply, state}
  end
end
