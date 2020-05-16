defmodule Kalevala.Websocket.Endpoint do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  match "/_health" do
    send_resp(conn, 200, "")
  end
end
