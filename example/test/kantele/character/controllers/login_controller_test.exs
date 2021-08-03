defmodule Kantele.Character.LoginControllerTest do
  use Kantele.ConnCase

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

      assert conn.flash[:login_state] == :username
    end
  end

  describe "requesting the username" do
    test "after initializing the controller accepts the username" do
      conn =
        build_conn(nil)
        |> put_flash(:login_state, :username)
        |> LoginController.recv("username")

      assert conn.flash[:username] == "username"

      assert conn.flash[:login_state] == :password
      assert process_output(conn) =~ ~r/Password:/
    end
  end

  describe "requesting the password" do
    test "after the username is the password" do
      conn =
        build_conn(nil)
        |> LoginController.init()
        |> put_flash(:login_state, :password)
        |> put_flash(:username, "username")
        |> LoginController.recv("password")

      assert conn.private.next_controller == Kantele.Character.CharacterController
      assert conn.private.next_controller_flash == %{}

      output = process_output(conn)

      assert output =~ ~r/Welcome username/
    end
  end

  describe "switching to registration" do
    test "confirming registering the character" do
      conn =
        build_conn(nil)
        |> LoginController.init()
        |> put_flash(:login_state, :registration)
        |> put_flash(:username, "new")
        |> LoginController.recv("y")

      assert conn.private.next_controller == Kantele.Character.RegistrationController
      assert conn.private.next_controller_flash == %{username: "new"}
    end
  end
end
