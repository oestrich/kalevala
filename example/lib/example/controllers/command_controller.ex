defmodule Example.CommandController do
  use Kalevala.Controller

  require Logger

  alias Example.Commands
  alias Example.CommandView
  alias Example.Events

  @impl true
  def init(conn) do
    prompt(conn, CommandView, "prompt", %{})
  end

  @impl true
  def recv(conn, ""), do: conn

  def recv(conn, data) do
    Logger.info("Received - #{inspect(data)}")

    case Commands.call(conn, data) do
      {:error, :unknown} ->
        conn
        |> render(CommandView, "unknown", %{})
        |> prompt(CommandView, "prompt", %{})

      conn ->
        prompt(conn, CommandView, "prompt", %{})
    end
  end

  @impl true
  def event(conn, event), do: Events.call(conn, event)
end
