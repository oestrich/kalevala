defmodule Sampo.LoginController do
  use Kalevala.Controller

  require Logger

  alias Sampo.CharacterView
  alias Sampo.CommandController
  alias Sampo.LoginView
  alias Sampo.QuitView

  @impl true
  def init(conn) do
    conn
    |> put_session(:login_state, :username)
    |> render(LoginView, "welcome", %{})
    |> prompt(LoginView, "name", %{})
  end

  @impl true
  def recv(conn, ""), do: conn

  def recv(conn, data) do
    case get_session(conn, :login_state) do
      :username ->
        process_username(conn, data)

      :password ->
        process_password(conn, data)
    end
  end

  defp process_username(conn, data) do
    name = String.trim(data)

    case name do
      "" ->
        prompt(conn, LoginView, "name", %{})

      <<4>> ->
        conn
        |> prompt(QuitView, "goodbye", %{})
        |> halt()

      "quit" ->
        conn
        |> prompt(QuitView, "goodbye", %{})
        |> halt()

      name ->
        conn
        |> put_session(:login_state, :password)
        |> put_session(:username, name)
        |> send_option(:echo, true)
        |> prompt(LoginView, "password", %{})
    end
  end

  defp process_password(conn, _data) do
    name = get_session(conn, :username)

    Logger.info("Signing in \"#{name}\"")

    conn
    |> put_session(:login_state, :authenticated)
    |> render(LoginView, "signed-in", %{username: name})
    |> render(CharacterView, "vitals", %{})
    |> send_option(:echo, false)
    |> put_controller(CommandController)
  end
end
