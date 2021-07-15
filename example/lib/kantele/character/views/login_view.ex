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
    %EventText{
      topic: "Login.PromptUsername",
      data: %{},
      text: ~s(What is your {color foreground="yellow"}name{/color}? )
    }
  end

  def render("password", _assigns) do
    %EventText{
      topic: "Login.PromptPassword",
      data: %{},
      text: "Password: "
    }
  end

  def render("signed-in", %{username: username}) do
    %EventText{
      topic: "Login.SignedIn",
      data: %{username: username},
      text: """

      Welcome {color foreground="yellow"}#{username}{/color}. Thanks for signing in.
      """
    }
  end

  def render("check-registration", %{username: username}) do
    [
      "{color foreground=\"yellow\"}#{username}{/color} does not exist already.\n",
      "Would you like to register this username? (y/n) "
    ]
  end

  def render("invalid-login", _assigns) do
    %EventText{
      topic: "Login.Invalid",
      data: %{},
      text: "Invalid name and password\n"
    }
  end
end
