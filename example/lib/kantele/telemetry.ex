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
    config = Application.get_env(:kantele, :telemetry, [])

    children = [
      {:telemetry_poller, measurements: [], period: 10_000},
      exporter(config)
    ]

    children =
      Enum.reject(children, fn child ->
        is_nil(child)
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp exporter(config) do
    case Keyword.get(config, :start, true) do
      true ->
        port = Keyword.get(config, :port, 9568)

        {TelemetryMetricsPrometheus, metrics: metrics(), port: port}

      false ->
        nil
    end
  end

  defp metrics() do
    [
      last_value("vm.memory.total", unit: :byte)
    ]
  end
end
