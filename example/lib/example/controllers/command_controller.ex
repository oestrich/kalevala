defmodule Example.CommandController do
  use Kalevala.Controller

  require Logger

  alias Example.CommandView

  @impl true
  def init(conn) do
    prompt(conn, CommandView, "prompt", %{})
  end

  @impl true
  def recv(conn, ""), do: conn

  def recv(conn, data) do
    Logger.info("Received - #{inspect(data)}")

    prompt(conn, CommandView, "prompt", %{})
  end
end
