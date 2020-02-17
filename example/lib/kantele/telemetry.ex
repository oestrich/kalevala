defmodule Kantele.Telemetry do
  @moduledoc """
  Supervisor for telemetry metrics
  """

  use Supervisor

  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: [], period: 10_000},
      {TelemetryMetricsPrometheus, metrics: metrics()},
      {Kantele.Telemetry.Logger, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp metrics() do
    [
      last_value("vm.memory.total", unit: :byte),
      distribution("kalevala.movement.voting.commit.total_time",
        unit: {:native, :second},
        buckets: [0.000000001, 0.0000001, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1]
      )
    ]
  end
end

defmodule Kantele.Telemetry.Logger do
  @moduledoc """
  GenServer to register telemetry events we want to log
  """

  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, %{}, {:continue, :register}}
  end

  def handle_continue(:register, state) do
    events = [
      [:kalevala, :movement, :voting, :request],
      [:kalevala, :movement, :voting, :commit],
      [:kalevala, :movement, :voting, :abort]
    ]

    :telemetry.attach_many(:voting, events, &handle_voting/4, %{})

    {:noreply, state}
  end

  @doc false
  def handle_voting([:kalevala, :movement, :voting, :request], event, _metadata, _config) do
    Logger.info(
      "Character #{event.character} wants to move from #{event.from} to #{event.to}",
      event
    )
  end

  def handle_voting([:kalevala, :movement, :voting, :commit], event, _metadata, _config) do
    Logger.info("Character #{event.character} is moving from #{event.from} to #{event.to}", event)
  end

  def handle_voting([:kalevala, :movement, :voting, :abort], event, _metadata, _config) do
    Logger.info(
      "Character #{event.character} failed moving from #{event.from} to #{event.to} with reason #{
        event.reason
      }",
      event
    )
  end
end
