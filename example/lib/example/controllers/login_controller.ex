defmodule Example.LoginController do
  use Kalevala.Controller

  require Logger

  alias Kalevala.Event

  @impl true
  def init(conn) do
    :timer.send_interval(1000, %Event{topic: "timer/send"})

    conn
  end

  @impl true
  def recv(conn, ""), do: conn

  def recv(conn, data) do
    Logger.info("Received - #{inspect(data)}")

    push(conn, String.trim(data) <> "\n", true)
  end

  @impl true
  def option(conn, option) do
    Logger.info("Received option - #{inspect(option)}")

    push(conn, "You wanted to alter a telnet option", true)
  end

  @impl true
  def event(conn, %Event{topic: "timer/send"}) do
    Logger.info("Timer ticked")

    push(conn, "This is the timer", true)
  end
end
