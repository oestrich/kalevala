defmodule Kalevala.Websocket.Listener do
  @moduledoc """
  Start a cowboy listener
  """

  use Supervisor

  def start_link(opts) do
    opts = Enum.into(opts, %{})
    Supervisor.start_link(__MODULE__, opts, Map.get(opts, :otp, []))
  end

  def init(config) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Kalevala.Websocket.Endpoint,
        options: [port: config[:port], dispatch: dispatch(config)]
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp dispatch(config) do
    dispatch_matches = Map.get(config, :dispatch_matches, [])

    [
      {:_,
       [
         {"/socket", Kalevala.Websocket.Handler, Map.take(config, [:foreman, :handler])}
         | dispatch_matches
       ]}
    ]
  end
end
