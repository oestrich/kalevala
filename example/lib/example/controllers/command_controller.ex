defmodule Example.CommandController do
  use Kalevala.Controller

  require Logger

  alias Example.CommandRouter
  alias Example.CommandView

  @impl true
  def init(conn) do
    prompt(conn, CommandView, "prompt", %{})
  end

  @impl true
  def recv(conn, ""), do: conn

  def recv(conn, data) do
    Logger.info("Received - #{inspect(data)}")

    case CommandRouter.call(conn, data) do
      {:error, :unknown} ->
        conn
        |> render(CommandView, "unknown", %{})
        |> prompt(CommandView, "prompt", %{})

      conn ->
        prompt(conn, CommandView, "prompt", %{})
    end
  end
end
