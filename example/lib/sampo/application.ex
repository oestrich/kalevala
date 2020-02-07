defmodule Sampo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    listener_config = [
      telnet: [
        port: 4444
      ],
      tls: [
        port: 4443,
        keyfile: Path.join(:code.priv_dir(:sampo), "certs/key.pem"),
        certfile: Path.join(:code.priv_dir(:sampo), "certs/cert.pem")
      ],
      foreman: [
        initial_controller: Sampo.LoginController
      ]
    ]

    children = [
      {Kalevala.Foreman.Supervisor, [name: Kalevala.Foreman.Supervisor]},
      {Kalevala.Telnet.Listener, listener_config}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sampo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
