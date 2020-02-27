defmodule Kalevala.World.Zone do
  @moduledoc """
  Zones group together Rooms into a logical space
  """

  use GenServer

  require Logger

  alias Kalevala.Event
  alias Kalevala.World.Zone.Movement

  defstruct [:id, :name, characters: [], rooms: []]

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
    genserver_options = options.genserver_options
    options = Map.delete(options, :genserver_options)

    GenServer.start_link(__MODULE__, options, genserver_options)
  end

  @impl true
  def init(options) do
    Logger.info("Zone starting - #{options.zone.id}")

    config = options.config
    zone = config.callback_module.init(options.zone)

    state = %{
      data: zone,
      supervisor_name: config.supervisor_name,
      callback_module: config.callback_module
    }

    {:ok, state}
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
