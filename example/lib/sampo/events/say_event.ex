defmodule Sampo.SayEvent do
  use Kalevala.Event

  alias Sampo.CommandView
  alias Sampo.SayView

  def echo(conn, event) do
    case event.from_pid == self() do
      true ->
        prompt(conn, CommandView, "prompt", %{})

      false ->
        conn
        |> render(SayView, "listen", event.data)
        |> prompt(CommandView, "prompt", %{})
    end
  end
end
