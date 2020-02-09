# Kalevala

Kalevala is a world building toolkit for text based games, written in Elixir.

## Example Game

There is an example game, Sampo, in the `example/` folder.

To start the game:

```bash
cd example/
mix deps.get
mix compile
mix run --no-halt
```

A telnet listener will start on `4444` and a TLS listener will start on `4443` with a self signed cert.

## Components of Kalevala

### Foreman

When you connect, a new `Kalevala.Foreman` process is started. This process handles incoming text from the player, sending out going text and events, and other orchestration.

### Conn

A `Kalevala.Conn` is the context token for controllers and commands. This is similar to a `Plug.Conn`. The main difference being it bundles up multiple renders and events to fire all at once, instead of being used for a single request.

The foreman will generate new `Conn`s before each event or incoming text. After processing the `Conn`, it is processed by sending text to the player and events sent to their router (more on this in a bit).

### Controllers

A `Kalevala.Controller` is the largest building block of handling texting. When starting the foreman, an initial controller is given. This controller is initialized and used from then on. The callbacks required will be called at the appropriate time with a new `Conn`.

Controllers act as a simple state machine, only allowing transitioning to the next one you set in the `Conn`. For instance, you can contain all login logic in a `LoginController`, and handle game commands in its own controller, any paging can be handled in a `PagerController` which can suppress any outgoing text to prevent scrolling while reading, etc.

```elixir
defmodule Sampo.CommandController do
  use Kalevala.Controller

  require Logger

  alias Sampo.Commands
  alias Sampo.CommandView

  @impl true
  def init(conn), do: prompt(conn, CommandView, "prompt", %{})

  @impl true
  def recv(conn, ""), do: conn

  def recv(conn, data) do
    Logger.info("Received - #{inspect(data)}")

    case Commands.call(conn, data) do
      {:error, :unknown} ->
        conn
        |> render(CommandView, "unknown", %{})
        |> prompt(CommandView, "prompt", %{})

      conn ->
      prompt(conn, CommandView, "prompt", %{})
    end
  end
end
```

### Commands

A `Kalevala.Command` is similar to a `Controller`, but should be called from a `Controller` through a `Command.Router`. Incoming text can be pattern matched in the router and be processed.

In the example below, you can `Sampo.Commands.call(conn, "say hello")` to run the `SayCommand.run/2` function.

```elixir
defmodule Sampo.Commands do
  use Kalevala.Commands.Router

  scope(Sampo) do
    module(SayCommand) do
      command("say :message", :run)
    end
  end
end

defmodule Sampo.SayCommand do
  use Kalevala.Command

  def run(conn, params) do
    params = %{
      "name" => character(conn).name,
      "message" => params["message"]
    }

    conn
    |> render(SayView, "echo", params)
    |> event("room/say", params)
  end
end
```

### Views

A `Kalevala.View` renders text and out of band events to the player. These are strings, IO data lists, or `Kalevala.Conn.Event` structs (which are used for GMCP in telnet.)

The sigil `~i` keeps a string as an IO data list, which is faster for processing and should be used if any interpolation is needed. Larger views can use the sigil `~E` to use EEx.

```elixir
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
```

### Events

A `Kalevala.Event` is an internal event passed between processes. Events have three fields, which pid is generating the event, the topic (e.g. `room/say`), and a map of data. Controllers and commands can generate events which will get sent to an event router process, which is typically the room they are in.

The `Kalevala.World.Room` process handles the event by running the event through a similar router to command processing. The `Foreman` process handles events with its own event router.

In the example below, you can call the event router with an event of topic `room/say` to run the `Sampo.World.Room.NotifyEvent.call/2` function.

```elixir
defmodule Sampo.World.Room.Events do
  @moduledoc false

  use Kalevala.Event.Router

  scope(Sampo.World.Room) do
    module(NotifyEvent) do
      event("room/say", :call)
    end
  end
end

defmodule Sampo.World.Room.NotifyEvent do
  import Kalevala.World.Room.Context

  def call(context, event) do
    Enum.reduce(context.characters, context, fn character, context ->
      event(context, character.pid, event.from_pid, event.topic, event.data)
    end)
  end
end
```

### The World

The world in Kalevala consists of `Kalevala.Zone`s and `Kalevala.Room`s. A zone contains many rooms, and rooms are the basic block of traversing the world. Rooms also act as the primary point of work (processing events) as all events will go through the room that characters are in.

The example game boots the world from flat files, but world data can come from any source as long as the structures can be created. For instance, you might load a simple zone struct with a database ID and hydrate the zone after the process started.
