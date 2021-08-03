defmodule Kalevala.Character.Controller do
  @moduledoc ~S"""
  A `Kalevala.Character.Controller` is the largest building block of handling 
  texting. When starting the foreman, an initial controller is given. This 
  controller is initialized and used from then on. The callbacks required will
  be called at the appropriate time with a new `Conn`.

  Controllers act as a simple state machine, only allowing transitioning to the 
  next one you set in the `Conn`. For instance, you can contain all login logic
  in a `LoginController`, and handle game commands in its own controller, any
  paging can be handled in a `PagerController` which can suppress any outgoing
  text to prevent scrolling while reading, etc.

  ## Example Controller

  ```elixir
    defmodule Kantele.Character.LoginController do
      use Kalevala.Character.Controller

      # ... code 
      
      @impl true
      def init(conn) do
        conn
        |> put_session(:login_state, :username)
        |> render(LoginView, "welcome")
        |> prompt(LoginView, "name")
      end

      @impl true
      def recv_event(conn, event) do
        case event.topic do
          "Login" ->
            conn
            |> process_username(event.data["username"])
            |> process_password(event.data["password"])

          _ ->
            conn
        end
      end

      @impl true
      def recv(conn, ""), do: conn

      def recv(conn, data) do
        data = String.trim(data)

        case get_session(conn, :login_state) do
          :username ->
            process_username(conn, data)

          :password ->
            process_password(conn, data)

          :registration ->
            process_registration(conn, data)
        end
      end

      defp process_username(conn, username) do
        case username do
          "" ->
            prompt(conn, LoginView, "name")

          <<4>> ->
            conn
            |> prompt(QuitView, "goodbye")
            |> halt()

          "quit" ->
            conn
            |> prompt(QuitView, "goodbye")
            |> halt()

          username ->
            case Accounts.exists?(username) do
              true ->
                conn
                |> put_session(:login_state, :password)
                |> put_session(:username, username)
                |> send_option(:echo, true)
                |> prompt(LoginView, "password")

              false ->
                conn
                |> put_session(:login_state, :registration)
                |> put_session(:username, username)
                |> prompt(LoginView, "check-registration")
            end
        end
      end

      # ... code ...
    end
  ```

  ## Managing State (assigns, session, and flash)

  Controller state is managed in one of three different ways, `session`, `assigns`, and
  `flash`. These states are made avaiable to the `Views` which can utilize them as
  variables as needed.

  ### Session

  The `session` maintains state for the lifetime of the player connection. Session state
  can be set using `put_session/3` and variables can be retrieved using `get_session/2`.

  ### Flash

  The `flash` maintains state for the duration of a player's interaction with a single
  controller. Switching between controllers will cause the flash to be reset.

  ### Assings

  Assigns are temporary storage that allow the setting of variables to be made available
  to `Views`  

  ## Prompts and Render

  A prompt is text that is sent followed by a newline character. The above code
  `prompt(LoginView, "check-registration")` will render the the 
  `"check-registration"` prompt of the `LoginView` followed by a newline.

  Render on the other outputs the text but is not followed by a newline. That
  means contiguous calls to `render` will append the output to the same line
  as the previous.

  ## Switching Controllers

  Switching controllers is done by calling the
  `Kalevala.Character.Conn.put_controller/2` function. This will immediately switch
  to the provided controller and call it's `init/1` function.
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
  Called when the connection receives an event (e.g. incoming GMCP)
  """
  @callback recv_event(Conn.t(), any()) :: Conn.t()

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
      def recv_event(conn, event) do
        Logger.debug("Received event - #{inspect(event)}")

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
        |> Map.put(:output, event.output)
      end

      defoverridable display: 2, event: 2, recv_event: 2
    end
  end
end
