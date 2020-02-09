defmodule Sampo.CommandController do
  use Kalevala.Controller

  require Logger

  alias Sampo.Commands
  alias Sampo.CommandView
  alias Sampo.Events

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
        case Map.get(conn.assigns, :prompt, true) do
          true ->
            prompt(conn, CommandView, "prompt", %{})

          false ->
            conn
        end
    end
  end

  @impl true
  def event(conn, event), do: Events.call(conn, event)

  @impl true
  def display(conn, event) do
    conn
    |> super(event)
    |> prompt(CommandView, "prompt", %{})
  end
end
