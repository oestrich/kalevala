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

      require Logger

      alias Kalevala.Event

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

      defoverridable option: 2, event: 2
    end
  end

  @doc """
  Push text back to the user
  """
  def push(conn, lines, newline \\ false) do
    lines = %Kalevala.Conn.Lines{data: lines, newline: newline}
    Map.put(conn, :lines, conn.lines ++ [lines])
  end

  @doc """
  Render text to the conn
  """
  def render(conn, view, template, assigns) do
    data = view.render(template, Map.merge(conn.assigns, assigns))

    push(conn, [data])
  end

  @doc """
  Render a prompt to the conn
  """
  def prompt(conn, view, template, assigns) do
    data = view.render(template, Map.merge(conn.assigns, assigns))

    push(conn, [data], true)
  end

  @doc """
  Put a value into the session data
  """
  def put_session(conn, key, value) do
    session = Map.put(conn.session, key, value)
    Map.put(conn, :session, session)
  end

  @doc """
  Get a value out of the session data
  """
  def get_session(conn, key), do: Map.get(conn.session, key)

  @doc """
  Put the new controller that the foreman should swap to
  """
  def put_controller(conn, controller) do
    Map.put(conn, :next_controller, controller)
  end

  @doc """
  Mark the connection for termination
  """
  def halt(conn) do
    private = Map.put(conn.private, :halt?, true)
    Map.put(conn, :private, private)
  end
end
