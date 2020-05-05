defmodule Kantele.MixProject do
  use Mix.Project

  def project do
    [
      app: :kantele,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Kantele.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:elias, "~> 0.2"},
      {:kalevala, path: "../"},
      {:telemetry_metrics, "~> 0.4.0"},
      {:telemetry_metrics_prometheus, "~> 0.3.1"},
      {:telemetry_poller, "~> 0.4.1"}
    ]
  end
end
