defmodule Kantele.AccountsTest do
  use ExUnit.Case

  alias Kantele.Accounts

  setup do
    on_exit(fn ->
      Accounts.delete("new")
    end)
  end

  describe "registering a new account" do
    test "successful" do
      {:ok, account} = Accounts.register("new", "password")

      assert account.username == "new"

      assert File.exists?("test/data/accounts/new.json")
    end

    test "does not overwrite existing users" do
      {:ok, _account} = Accounts.register("new", "password")

      {:error, error} = Accounts.register("new", "password")

      assert error.reason == :exists
      assert error.message == "Account already exists"
    end
  end

  describe "signing in" do
    test "successful" do
      {:ok, _account} = Accounts.register("new", "password")

      {:ok, account} = Accounts.validate_login("new", "password")

      assert account.username == "new"
    end

    test "failure: invalid password" do
      {:ok, _account} = Accounts.register("new", "password")

      {:error, error} = Accounts.validate_login("new", "passw0rd")

      assert error.message == "Invalid password"
    end

    test "failure: invalid account" do
      {:error, error} = Accounts.validate_login("new", "password")

      assert error.message == "Invalid password"
    end
  end
end
