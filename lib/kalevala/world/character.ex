defmodule Kalevala.World.Character do
  @moduledoc """
  GenServer for tracking characters that the world runs

  World characters are non-player characters (NPCs), and act
  as full characters.
  """

  use GenServer

  require Logger

  alias Kalevala.Character
  alias Kalevala.Character.Conn
  alias Kalevala.Character.Foreman
  alias Kalevala.Event

  defstruct [
    :callback_module,
    :character,
    :character_module,
    :communication_module,
    :supervisor_name,
    session: %{}
  ]

  @doc """
  Called when the world character is initializing
  """
  @callback init(character :: Character.t()) :: Character.t()

  @doc """
  Called after the world character is started

  Directly after `init` is completed.
  """
  @callback initialized(character :: Character.t()) :: Character.t()

  @doc """
  Callback for when a new event is received
  """
  @callback event(Conn.t(), event :: Event.t()) :: Conn.t()

  @doc """
  Callback for when the character should be spawned and join the world

  You *must* move into the room in this function. This let's you customize
  the spawn message through the callback.
  """
  @callback spawn(Conn.t()) :: Conn.t()

  @doc false
  def global_name(character = %Character{}), do: global_name(character.id)

  def global_name(character_id), do: {:global, {__MODULE__, character_id}}

  @doc false
  def start_link(options) do
    genserver_options = options.genserver_options
    options = Map.delete(options, :genserver_options)

    GenServer.start_link(__MODULE__, options, genserver_options)
  end

  @impl true
  def init(options) do
    Logger.info("Character starting - #{options.character.id}")

    config = options.config
    character = config.callback_module.init(options.character)

    state = %__MODULE__{
      supervisor_name: config.supervisor_name,
      character_module: config.character_module,
      callback_module: config.callback_module,
      communication_module: config.communication_module,
      character: %{character | pid: self()}
    }

    {:ok, state, {:continue, :initialized}}
  end

  @impl true
  def handle_continue(:initialized, state) do
    # move into the room, we need a view module and template to render...
    state.callback_module.initialized(state.character)
    {:noreply, state, {:continue, :spawn}}
  end

  def handle_continue(:spawn, state) do
    Foreman.new_conn(state)
    |> state.callback_module.spawn()
    |> Foreman.handle_conn(state)
  end

  @impl true
  def handle_info(_event = %Event{}, state) do
    {:noreply, state}
  end

  def handle_info(_event = %Event.Display{}, state) do
    {:noreply, state}
  end
end
