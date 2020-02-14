defmodule Kalevala.MixProject do
  use Mix.Project

  def project do
    [
      app: :kalevala,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Kalevala.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false},
      {:ranch, "~> 1.7"},
      {:telemetry, "~> 0.4.1"},
      {:telnet, "~> 0.1"}
    ]
  end
end
