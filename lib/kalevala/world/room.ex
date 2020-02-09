defmodule Kalevala.World.Room do
  @moduledoc """
  Rooms are the base unit of space in Kalevala
  """

  use GenServer

  require Logger

  alias Kalevala.Event

  defstruct [:id, :zone_id, :name, :description, exits: []]

  @type t() :: %__MODULE__{}

  @doc """
  Called when the zone is initializing
  """
  @callback init(zone :: t()) :: t()

  @doc """
  Callback for when a new event is received
  """
  @callback event(t(), event :: Event.t()) :: t()

  @doc false
  def global_name(room = %__MODULE__{}), do: global_name(room.id)

  def global_name(room_id), do: {:global, {__MODULE__, room_id}}

  @doc false
  def start_link(options) do
    otp_options = options.otp
    options = Map.delete(options, :otp)

    GenServer.start_link(__MODULE__, options, otp_options)
  end

  @impl true
  def init(state) do
    Logger.info("Room starting - #{state.room.id}")

    config = state.config
    room = config.callback_module.init(state.room)

    state = %{
      data: room,
      supervisor: config.supervisor,
      callback_module: config.callback_module
    }

    {:ok, state}
  end

  @impl true
  def handle_info(event = %Event{}, state) do
    data = state.callback_module.event(state.data, event)
    state = Map.put(state, :data, data)

    {:noreply, state}
  end
end
