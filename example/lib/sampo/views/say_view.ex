defmodule Sampo.SayView do
  use Kalevala.View

  def render("echo", %{"message" => message}) do
    ~s(You say, "\e[32m#{message}\e[0m"\n)
  end
end
