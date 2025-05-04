defmodule Kalevala.MixProject do
  use Mix.Project

  def project do
    [
      app: :kalevala,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/oestrich/kalevala",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
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
      {:benchee, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:nimble_parsec, "~> 1.0"},
      {:plug_cowboy, "~> 2.2", optional: true},
      {:ranch, "~> 1.7", optional: true},
      {:telemetry, "~> 0.4.1"},
      {:telnet, "~> 0.1"}
    ]
  end

  defp description() do
    """
    Kalevala is a world building toolkit for text based games.
    """
  end

  defp package() do
    [
      maintainers: ["Eric Oestrich"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/oestrich/kalevala"
      }
    ]
  end
end
