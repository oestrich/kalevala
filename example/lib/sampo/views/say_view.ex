defmodule Sampo.SayView do
  use Kalevala.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("echo", %{"message" => message}) do
    ~i(You say, "\e[32m#{message}\e[0m"\n)
  end

  def render("listen", %{"character_name" => character_name, "message" => message}) do
    ~i(#{white()}#{character_name}#{reset()} says, "\e[32m#{message}\e[0m"\n)
  end
end
