defmodule Kalevala.World.Zone do
  @moduledoc """
  Zones group together Rooms into a logical space
  """

  use GenServer

  require Logger

  alias Kalevala.Event
  alias Kalevala.World
  alias Kalevala.World.RoomSupervisor
  alias Kalevala.World.Zone.Movement

  defstruct [:id, :name, rooms: []]

  @type t() :: %__MODULE__{}

  @doc """
  Called when the zone is initializing
  """
  @callback init(zone :: t()) :: t()

  @doc false
  def global_name(zone = %__MODULE__{}), do: global_name(zone.id)

  def global_name(zone_id), do: {:global, {__MODULE__, zone_id}}

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

  @impl true
  def handle_info(event = %Event{topic: Event.Movement.Voting}, state) do
    Movement.handle_voting(event)

    {:noreply, state}
  end
end

defmodule Kalevala.World.Zone.Movement do
  @moduledoc """
  Zone movement functions
  """

  alias Kalevala.Event
  alias Kalevala.Event.Movement.Voting
  alias Kalevala.World.Room

  def handle_voting(event) do
    event
    |> Room.confirm_movement(event.data.from)
    |> Room.confirm_movement(event.data.to)
    |> handle_response()

    {:ok, event}
  end

  defp handle_response(event = %Event{topic: Voting, data: %{aborted: true}}) do
    %{character: character} = event.data

    send(character.pid, Voting.abort(event))
  end

  defp handle_response(event = %Event{topic: Voting}) do
    %{character: character} = event.data

    send(character.pid, Voting.commit(event))
  end
end
