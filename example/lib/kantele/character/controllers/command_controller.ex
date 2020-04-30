defmodule Kantele.Character.CommandController do
  use Kalevala.Character.Controller

  require Logger

  alias Kalevala.Output.Tags
  alias Kantele.Character.Commands
  alias Kantele.Character.CommandView
  alias Kantele.Character.Events

  @impl true
  def init(conn) do
    prompt(conn, CommandView, "prompt", %{})
  end

  @impl true
  def recv(conn, ""), do: conn

  def recv(conn, data) do
    Logger.info("Received - #{inspect(data)}")

    data = Tags.escape(data)

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
