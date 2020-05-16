defmodule Kantele.Websocket.Endpoint do
  use Plug.Router

  plug(Plug.Static, at: "/", gzip: true, only: ["js", "css", "robots.txt"], from: :kantele)

  plug(:match)
  plug(:dispatch)

  match "/" do
    index_file = Path.join(:code.priv_dir(:kantele), "static/index.html")
    send_resp(conn, 200, File.read!(index_file))
  end

  match "/_health" do
    send_resp(conn, 200, "")
  end

  match "/version" do
    send_resp(conn, 200, Jason.encode!(%{version: Kalevala.version()}))
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
