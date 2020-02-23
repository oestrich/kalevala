defmodule Kantele.Character.SayView do
  use Kalevala.Character.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("echo", %{text: text}) do
    ~i(You say, "\e[32m#{text}\e[0m"\n)
  end

  def render("listen", %{character_name: character_name, text: text}) do
    ~i(#{white()}#{character_name}#{reset()} says, "\e[32m#{text}\e[0m"\n)
  end
end
