defmodule Kalevala.World.Zone do
  @moduledoc """
  Zones group together Rooms into a logical space
  """

  use GenServer

  require Logger

  alias Kalevala.World
  alias Kalevala.World.RoomSupervisor

  defstruct [:id, :name, rooms: []]

  @type t() :: %__MODULE__{}

  @doc """
  Called when the zone is initializing
  """
  @callback init(zone :: t()) :: t()

  @doc false
  def global_name(zone), do: {:global, {__MODULE__, zone.id}}

  @doc false
  def start_link(options) do
    otp_options = options.otp
    options = Map.delete(options, :otp)

    GenServer.start_link(__MODULE__, options, otp_options)
  end

  @impl true
  def init(state) do
    Logger.info("Zone starting - #{state.zone.id}")

    config = state.config
    zone = config.callback_module.init(state.zone)

    state = %{
      data: zone,
      supervisor: config.supervisor,
      callback_module: config.callback_module
    }

    {:ok, state, {:continue, {:start_rooms, config}}}
  end

  @impl true
  def handle_continue({:start_rooms, config}, state) do
    room_config = %{
      supervisor: RoomSupervisor.global_name(state.data),
      callback_module: config.rooms.callback_module
    }

    Enum.each(state.data.rooms, fn room ->
      World.start_room(room, room_config)
    end)

    {:noreply, state}
  end
end
