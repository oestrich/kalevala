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
      {TelemetryMetricsPrometheus, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp metrics() do
    [
      last_value("vm.memory.total", unit: :byte)
    ]
  end
end
