defmodule Kantele.Character.ChannelView do
  use Kalevala.Character.View

  alias Kantele.Character.CharacterView

  def render("name", %{name: name}) do
    ~i({color foreground="white"}[#{name}]{/color})
  end

  def render("echo", %{channel_name: channel_name, text: text}) do
    [
      render("name", %{name: channel_name}),
      ~i( You say, ),
      ~i("{color foreground="green"}#{text}{/color}"\n)
    ]
  end

  def render("listen", %{channel_name: channel_name, character: character, text: text}) do
    [
      render("name", %{name: channel_name}),
      ~i( #{CharacterView.render("name", %{character: character})} says, ),
      ~i("{color foreground="green"}#{text}{/color}"\n)
    ]
  end
end
