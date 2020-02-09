defmodule Sampo.LookView do
  use Kalevala.View

  import IO.ANSI, only: [reset: 0, white: 0]

  def render("look", %{room: room}) do
    ~E"""
    <%= white() %><%= room.name %><%= reset() %>

    <%= room.description %>
    """
  end
end
