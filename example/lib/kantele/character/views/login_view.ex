defmodule Kantele.Character.LoginView do
  use Kalevala.Character.View

  alias Kalevala.Character.Conn.EventText

  def render("welcome", assigns) do
    %EventText{
      topic: "Login.Welcome",
      data: %{powered_by: "Kalevala #{Kalevala.version()}"},
      text: render("welcome.text", assigns)
    }
  end

  def render("welcome.text", _assigns) do
    ~E"""
    Welcome to
    {color foreground="256:39"}
     __   ___       __      _____  ___  ___________  _______  ___       _______
    |/"| /  ")     /""\    (\"   \|"  \("     _   ")/"     "||"  |     /"     "|
    (: |/   /     /    \   |.\\   \    |)__/  \\__/(: ______)||  |    (: ______)
    |    __/     /' /\  \  |: \.   \\  |   \\_ /    \/    |  |:  |     \/    |
    (// _  \    //  __'  \ |.  \    \. |   |.  |    // ___)_  \  |___  // ___)_
    |: | \  \  /   /  \\  \|    \    \ |   \:  |   (:      "|( \_|:  \(:      "|
    (__|  \__)(___/    \___)\___|\____\)    \__|    \_______) \_______)\_______)
    {/color}

    <%= render("powered-by", %{}) %>
    """
  end

  def render("powered-by", _assigns) do
    [
      ~s(Powered by {color foreground="256:39"}Kalevala{/color} 🧝 ),
      ~s({color foreground="cyan"}v#{Kalevala.version()}{/color}.)
    ]
  end

  def render("name", _assigns) do
    ~s(What is your {color foreground="white"}name{/color}? )
  end

  def render("password", _assigns) do
    "Password: "
  end

  def render("signed-in", %{username: username}) do
    """

    Welcome {color foreground="white"}#{username}{/color}. Thanks for signing in.
    """
  end

  def render("character-name", _assigns) do
    "What is your character name? "
  end

  def render("enter-world", %{character: character}) do
    """
    Welcome to the world of {color foreground="256:39"}Kantele{/color}, {color foreground="white"}#{
      character.name
    }{/color}.
    """
  end
end
