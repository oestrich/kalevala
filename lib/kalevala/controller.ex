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

  # Push text back to the user
  defp push(conn, data, newline \\ false)

  defp push(conn, event = %Kalevala.Conn.Event{}, _newline) do
    Map.put(conn, :lines, conn.lines ++ [event])
  end

  defp push(conn, data, newline) do
    lines = %Kalevala.Conn.Lines{
      data: data,
      newline: newline
    }

    Map.put(conn, :lines, conn.lines ++ [lines])
  end

  @doc """
  Render text to the conn
  """
  def render(conn, view, template, assigns) do
    assigns =
      conn.session
      |> Map.merge(conn.assigns)
      |> Map.merge(assigns)

    data = view.render(template, assigns)

    push(conn, data)
  end

  @doc """
  Render a prompt to the conn
  """
  def prompt(conn, view, template, assigns) do
    assigns =
      conn.session
      |> Map.merge(conn.assigns)
      |> Map.merge(assigns)

    data = view.render(template, assigns)

    push(conn, data, true)
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

  @doc """
  Send the foreman an in-game event
  """
  def event(conn, topic, data) do
    event = %Kalevala.Event{
      to_pid: self(),
      from_pid: self(),
      topic: topic,
      data: data
    }

    Map.put(conn, :events, conn.events ++ [event])
  end

  @doc """
  """
  def send_option(conn, name, value) when is_boolean(value) do
    option = %Kalevala.Conn.Option{name: name, value: value}
    Map.put(conn, :options, conn.options ++ [option])
  end
end
