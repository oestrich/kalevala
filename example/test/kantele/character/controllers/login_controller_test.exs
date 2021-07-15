defmodule Kantele.Character.LoginControllerTest do
  use Kantele.ConnCase, async: true

  alias Kalevala.Character.Conn
  alias Kantele.Character.LoginController

  describe "initializing the controller" do
    test "says welcome" do
      output =
        build_conn(nil)
        |> LoginController.init()
        |> process_output()

      assert output =~ ~r/Powered by Kalevala/
      assert output =~ ~r/What is your name\?/
    end

    test "sets the login state to asking for the username" do
      conn =
        build_conn(nil)
        |> LoginController.init()

      assert conn.session[:login_state] == :username
    end
  end

  describe "requesting the username" do
    test "after initializing the controller accepts the username" do
      conn =
        build_conn(nil)
        |> LoginController.init()
        |> refresh_conn()
        |> LoginController.recv("username")

      assert conn.session[:username] == "username"

      assert conn.session[:login_state] == :password
      assert process_output(conn) =~ ~r/Password:/
    end
  end

  describe "requesting the password" do
    test "after the username is the password" do
      conn =
        build_conn(nil)
        |> LoginController.init()
        |> put_session(:login_state, :password)
        |> put_session(:username, "username")
        |> LoginController.recv("password")

      assert conn.session[:login_state] == :character

      output = process_output(conn)

      assert output =~ ~r/Welcome username/
      assert output =~ ~r/What is your character name?/
    end
  end

  describe "requesting the character name" do
    test "after the password is the character name" do
      conn =
        build_conn(nil)
        |> put_session(:login_state, :character)
        |> LoginController.recv("character")

      assert conn.session[:login_state] == :authenticated

      character = Conn.character(conn)
      assert character.name == "character"
    end
  end
end
