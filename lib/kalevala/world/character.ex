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
  alias Kalevala.Event

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

    state = %{
      data: character,
      supervisor: config.supervisor,
      callback_module: config.callback_module
    }

    {:ok, state, {:continue, :initialized}}
  end

  @impl true
  def handle_continue(:initialized, state) do
    # move into the room, we need a view module and template to render...
    state.callback_module.initialized(state.data)
    {:noreply, state}
  end
end
