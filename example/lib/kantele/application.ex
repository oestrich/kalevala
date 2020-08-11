defmodule Kantele.Application do
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
        keyfile: Path.join(:code.priv_dir(:kantele), "certs/key.pem"),
        certfile: Path.join(:code.priv_dir(:kantele), "certs/cert.pem")
      ],
      protocol: [
        output_processors: [
          Kalevala.Output.Tags,
          Kantele.Output.AdminTags,
          Kantele.Output.SemanticColors,
          Kalevala.Output.Tables,
          Kalevala.Output.TagColors,
          Kalevala.Output.StripTags
        ]
      ],
      foreman: [
        supervisor_name: Kantele.Character.Foreman.Supervisor,
        communication_module: Kantele.Communication,
        initial_controller: Kantele.Character.LoginController,
        presence_module: Kantele.Character.Presence,
        quit_view: {Kantele.Character.QuitView, "disconnected"}
      ]
    ]

    websocket_config = [
      port: 4500,
      dispatch_matches: [
        {:_, Plug.Cowboy.Handler, {Kantele.Websocket.Endpoint, []}}
      ],
      handler: [
        output_processors: [
          Kalevala.Output.Tags,
          Kantele.Output.AdminTags,
          Kantele.Output.SemanticColors,
          Kantele.Output.Tooltips,
          Kalevala.Output.Tables,
          Kalevala.Output.Websocket
        ]
      ],
      foreman: [
        supervisor_name: Kantele.Character.Foreman.Supervisor,
        communication_module: Kantele.Communication,
        initial_controller: Kantele.Character.LoginController,
        presence_module: Kantele.Character.Presence,
        quit_view: {Kantele.Character.QuitView, "disconnected"}
      ]
    ]

    children = [
      {Kantele.Config, [name: Kantele.Config]},
      {Kantele.Communication, []},
      {Kantele.World, []},
      {Kantele.Character.Presence, []},
      {Kantele.Character.Emotes, [name: Kantele.Character.Emotes]},
      {Kalevala.Character.Foreman.Supervisor, [name: Kantele.Character.Foreman.Supervisor]},
      listener(listener_config),
      {Kalevala.Websocket.Listener, websocket_config},
      {Kantele.Telemetry, []}
    ]

    children =
      Enum.reject(children, fn child ->
        is_nil(child)
      end)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kantele.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def listener(listener_config) do
    config = Application.get_env(:kantele, :listener, [])

    case Keyword.get(config, :start, true) do
      true ->
        {Kalevala.Telnet.Listener, listener_config}

      false ->
        nil
    end
  end
end
