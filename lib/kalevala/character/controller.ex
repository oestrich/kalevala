defmodule Kalevala.Character.Controller do
  @moduledoc """
  Kalevala controllers are the current set of actions for the user

  For instance, you might have a LoginController that handles
  authentication, that then passes to a CommandController to start
  processing player commands after they signed in.
  """

  alias Kalevala.Character.Conn
  alias Kalevala.Character.Event

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
  Called when a `Kalevala.Character.Event` is sent to the foreman process
  """
  @callback event(Conn.t(), Event.t()) :: Conn.t()

  @doc """
  Called when a `Kalevala.Character.Event.Display` is sent to the foreman process
  """
  @callback display(Conn.t(), Event.t()) :: Conn.t()

  @doc """
  Marks the module as a controller and imports controller functions
  """
  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)

      import Kalevala.Character.Conn

      require Logger

      alias Kalevala.Character.Event

      @impl true
      def option(conn, option) do
        Logger.debug("Received option - #{inspect(option)}")

        conn
      end

      @impl true
      def event(conn, event) do
        Logger.debug("Received event - #{inspect(event)}")

        conn
      end

      @impl true
      def display(conn, event) do
        conn
        |> Map.put(:options, event.options)
        |> Map.put(:lines, event.lines)
      end

      defoverridable display: 2, event: 2, option: 2
    end
  end
end
