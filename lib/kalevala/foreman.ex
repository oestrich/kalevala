defmodule Kalevala.Foreman do
  @moduledoc """
  Session Foreman

  Manages data flowing from the player into the game.
  """

  use GenServer

  require Logger

  alias Kalevala.Conn
  alias Kalevala.Event

  defstruct [:protocol, :controller, :options]

  @doc """
  Start a new foreman for a connecting player
  """
  def start(protocol_pid, options) do
    options = Keyword.merge(options, protocol: protocol_pid)
    DynamicSupervisor.start_child(__MODULE__.Supervisor, {__MODULE__, options})
  end

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @impl true
  def init(opts) do
    opts = Enum.into(opts, %{})

    state = %__MODULE__{
      protocol: opts[:protocol],
      controller: opts.initial_controller,
      options: %{}
    }

    {:ok, state, {:continue, :init_controller}}
  end

  @impl true
  def handle_continue(:init_controller, state) do
    %Conn{}
    |> state.controller.init()
    |> handle_conn(state)
  end

  @impl true
  def handle_info({:recv, :text, data}, state) do
    %Conn{}
    |> state.controller.recv(data)
    |> handle_conn(state)
  end

  def handle_info({:recv, :option, option}, state) do
    %Conn{}
    |> state.controller.option(option)
    |> handle_conn(state)
  end

  def handle_info(event = %Event{}, state) do
    %Conn{}
    |> state.controller.event(event)
    |> handle_conn(state)
  end

  def handle_info(:terminate, state) do
    DynamicSupervisor.terminate_child(__MODULE__.Supervisor, self())
    {:noreply, state}
  end

  def handle_conn(conn, state) do
    Enum.each(conn.lines, fn line ->
      send(state.protocol, {:send, line})
    end)

    {:noreply, state}
  end
end
