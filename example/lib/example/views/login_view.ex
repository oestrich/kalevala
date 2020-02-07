defmodule Example.LoginView do
  use Kalevala.View

  def render("welcome", _assigns) do
    "Welcome to \e[38;5;39mKalevala\e[0m.\n\n"
  end

  def render("name", _assigns) do
    "What is your \e[37mname\e[0m? "
  end

  def render("signed-in", %{username: username}) do
    "Welcome \e[37m#{username}\e[0m. Thanks for signing in.\n"
  end

  def render("goodbye", _assigns) do
    "Goodbye!\n"
  end
end
