defmodule Example.LoginController do
  use Kalevala.Controller

  require Logger

  alias Example.CommandController
  alias Example.LoginView

  @impl true
  def init(conn) do
    conn
    |> put_session(:login_state, :unauthenticated)
    |> render(LoginView, "welcome", %{})
    |> prompt(LoginView, "name", %{})
  end

  @impl true
  def recv(conn, ""), do: conn

  def recv(conn, data) do
    Logger.info("Received - #{inspect(data)}")

    name = String.trim(data)

    case name do
      "" ->
        prompt(conn, LoginView, "name", %{})

      "quit" ->
        conn
        |> prompt(LoginView, "goodbye", %{})
        |> halt()

      name ->
        conn
        |> put_session(:login_state, :authenticated)
        |> put_session(:username, name)
        |> render(LoginView, "signed-in", %{username: name})
        |> put_controller(CommandController)
    end
  end
end
