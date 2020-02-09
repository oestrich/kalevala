defmodule Sampo.LoginController do
  use Kalevala.Controller

  require Logger

  alias Sampo.CharacterView
  alias Sampo.CommandController
  alias Sampo.LoginView
  alias Sampo.MoveView
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

      :character ->
        process_character(conn, data)
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
    |> put_session(:login_state, :character)
    |> send_option(:echo, false)
    |> render(LoginView, "signed-in", %{})
    |> prompt(LoginView, "character-name", %{})
  end

  defp process_character(conn, character_name) do
    character =
      character_name
      |> String.trim()
      |> build_character()

    conn
    |> put_session(:login_state, :authenticated)
    |> put_character(character)
    |> render(CharacterView, "vitals", %{})
    |> move(:to, character.room_id, MoveView, "enter", %{})
    |> prompt(LoginView, "enter-world", %{})
    |> put_controller(CommandController)
  end

  defp build_character(name) do
    id =
      :crypto.hash(:sha256, name)
      |> Base.encode64()

    starting_room_id =
      Sampo.Config.get([:player, :starting_room_id])
      |> Sampo.World.dereference()

    %Kalevala.Character{
      id: id,
      pid: self(),
      room_id: starting_room_id,
      name: name,
      status: "#{name} is here.",
      description: "#{name} is a person.",
      meta: %Sampo.Character.Meta{
        vitals: %Sampo.Character.Vitals{
          health_points: 25,
          max_health_points: 25
        }
      }
    }
  end
end
