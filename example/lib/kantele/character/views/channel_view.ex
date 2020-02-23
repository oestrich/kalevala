defmodule Kantele.Character.ChannelView do
  use Kalevala.Character.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("echo", %{channel_name: channel_name, text: text}) do
    [
      ~i(#{white()}[#{channel_name}]#{reset()} You say, ),
      ~i("\e[32m#{text}\e[0m"\n)
    ]
  end

  def render("listen", %{channel_name: channel_name, character_name: character_name, text: text}) do
    [
      ~i(#{white()}[#{channel_name}]#{reset()} #{white()}#{character_name}#{reset()} says, ),
      ~i("\e[32m#{text}\e[0m"\n)
    ]
  end
end
