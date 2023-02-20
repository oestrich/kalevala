defmodule Kalevala.World.Zone do
  @moduledoc """
  Zones group together Rooms into a logical space
  """

  use GenServer

  require Logger

  alias Kalevala.Event
  alias Kalevala.World.Zone.Movement
  alias Kalevala.World.Zone.Handler
  alias Kalevala.World.Zone.Callbacks
  alias Kalevala.World.Zone.Context

  @type t() :: map()

  @doc """
  Replace internal zone state
  """
  def update(pid, zone) do
    GenServer.call(pid, {:update, zone})
  end

  @doc false
  def global_name(%{id: zone_id}), do: global_name(zone_id)

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
    zone = Callbacks.init(options.zone)

    state = %{
      data: zone,
      supervisor_name: config.supervisor_name,
      callback_module: config.callback_module
    }

    {:ok, state, {:continue, :initialized}}
  end

  @impl true
  def handle_continue(:initialized, state) do
    Callbacks.initialized(state.data)
    {:noreply, state}
  end

  @impl true
  def handle_call({:update, zone}, _from, state) do
    state = %{state | data: zone}
    {:reply, :ok, state}
  end

  @impl true
  def handle_info(event = %Event{topic: Event.Movement.Voting}, state) do
    Movement.handle_voting(event)

    {:noreply, state}
  end

  @impl true
  def handle_info(event = %Event{}, state) do
    context =
      state
      |> Handler.event(event)
      |> Context.handle_context()

    state = Map.put(state, :data, context.data)

    {:noreply, state}
  end
end

defmodule Kalevala.World.Zone.Handler do
  @moduledoc false

  alias Kalevala.World.Zone.Callbacks
  alias Kalevala.World.Zone.Context

  def event(state, event) do
    Callbacks.event(state.data, Context.new(state), event)
  end
end

defprotocol Kalevala.World.Zone.Callbacks do
  @doc """
  Called when the zone is initializing
  """
  def init(zone)

  @doc """
  Called after the zone process is started

  Directly after `init` is completed.
  """
  def initialized(zone)

  @doc """
  Callback for when a new event is received
  """
  def event(zone, context, event)
end

defmodule Kalevala.World.BasicZone do
  @moduledoc """
  A basic Zone

  These are the minimum fields a zone should have. You likely want more, so
  you can create your own local struct with these and more fields.
  """

  defstruct [:id]
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
