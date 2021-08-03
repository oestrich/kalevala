defmodule Kantele.Character.LoginController do
  @moduledoc """
  Sign into your account

  If the account is not found, will transfer you to registration optionally
  """

  use Kalevala.Character.Controller

  require Logger

  alias Kantele.Accounts
  alias Kantele.Character.CharacterController
  alias Kantele.Character.LoginView
  alias Kantele.Character.RegistrationController
  alias Kantele.Character.QuitView

  @impl true
  def init(conn) do
    conn
    |> put_flash(:login_state, :username)
    |> render(LoginView, "welcome")
    |> prompt(LoginView, "name")
  end

  @impl true
  def recv_event(conn, event) do
    case event.topic do
      "Login" ->
        conn
        |> process_username(event.data["username"])
        |> process_password(event.data["password"])

      _ ->
        conn
    end
  end

  @impl true
  def recv(conn, ""), do: conn

  def recv(conn, data) do
    data = String.trim(data)

    case get_flash(conn, :login_state) do
      :username ->
        process_username(conn, data)

      :password ->
        process_password(conn, data)

      :registration ->
        process_registration(conn, data)
    end
  end

  defp process_username(conn, username) do
    case username do
      "" ->
        prompt(conn, LoginView, "name")

      <<4>> ->
        conn
        |> prompt(QuitView, "goodbye")
        |> halt()

      "quit" ->
        conn
        |> prompt(QuitView, "goodbye")
        |> halt()

      username ->
        case Accounts.exists?(username) do
          true ->
            conn
            |> put_flash(:login_state, :password)
            |> put_session(:username, username)
            |> send_option(:echo, true)
            |> prompt(LoginView, "password")

          false ->
            conn
            |> put_flash(:login_state, :registration)
            |> put_session(:username, username)
            |> prompt(LoginView, "check-registration")
        end
    end
  end

  defp process_password(conn, password) do
    username = get_session(conn, :username)

    case Accounts.validate_login(username, password) do
      {:ok, account} ->
        Logger.info("Signing in \"#{account.username}\"")

        conn
        |> put_flash(:login_state, :character)
        |> send_option(:echo, false)
        |> render(LoginView, "signed-in")
        |> put_controller(CharacterController)

      {:error, %{reason: :invalid}} ->
        conn
        |> put_flash(:login_state, :username)
        |> send_option(:echo, false)
        |> render(LoginView, "invalid-login")
        |> prompt(LoginView, "name")
    end
  end

  defp process_registration(conn, "y") do
    put_controller(conn, RegistrationController)
  end

  defp process_registration(conn, _data) do
    put_controller(conn, __MODULE__)
  end
end
