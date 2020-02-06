defmodule Kalevala.Controller do
  @moduledoc """
  Kalevala controllers are the current set of actions for the user

  For instance, you might have a LoginController that handles
  authentication, that then passes to a CommandController to start
  processing player commands after they signed in.
  """

  alias Kalevala.Conn
  alias Kalevala.Event

  @doc """
  Called when the controller is first switched to
  """
  @callback init(Conn.t()) :: Conn.t()

  @doc """
  Called when text is received from the player
  """
  @callback recv(Conn.t(), String.t()) :: Conn.t()

  @doc """
  Called when a telnet option is sent
  """
  @callback option(Conn.t(), any()) :: Conn.t()

  @doc """
  Called when a `Kalevala.Event` is sent to the foreman process
  """
  @callback event(Conn.t(), Event.t()) :: Conn.t()

  @doc """
  Marks the module as a controller and imports controller functions
  """
  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)

      import unquote(__MODULE__)
    end
  end

  @doc """
  Push text back to the user
  """
  def push(conn, lines, newline \\ false) do
    lines = %Kalevala.Conn.Lines{data: lines, newline: newline}
    Map.put(conn, :lines, conn.lines ++ [lines])
  end
end
