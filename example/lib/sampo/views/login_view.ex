defmodule Sampo.LoginView do
  use Kalevala.View

  def render("welcome", _assigns) do
    ~i"""
    Welcome to
    \e[38;5;39m
     _____
    /  ___|
    \\ `--.  __ _ _ __ ___  _ __   ___
     `--. \\/ _` | '_ ` _ \\| '_ \\ / _ \\
    /\\__/ / (_| | | | | | | |_) | (_) |
    \\____/ \\__,_|_| |_| |_| .__/ \\___/
                          | |
                          |_|
    \e[0m

    Powered by \e[38;5;39mKalevala\e[0m 🧝 \e[36mv#{Kalevala.version()}\e[0m.
    """
  end

  def render("name", _assigns) do
    "What is your \e[37mname\e[0m? "
  end

  def render("password", _assigns) do
    "Password: "
  end

  def render("signed-in", %{username: username}) do
    """

    Welcome \e[37m#{username}\e[0m. Thanks for signing in.
    """
  end

  def render("character-name", _assigns) do
    "What is your character name? "
  end

  def render("enter-world", %{character: character}) do
    """
    Welcome to the world of \e[38;5;39mSampo\e[0m, \e[37m#{character.name}\e[0m.
    """
  end
end
