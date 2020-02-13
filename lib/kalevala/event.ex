defmodule Kalevala.Event.Movement do
  @moduledoc """
  An event to move from one room to another
  """

  defstruct [:character, :direction, :reason, :room_id]

  @typedoc """
  A movement event

  - `character` is the character performing the movement
  - `direction` is one of two options, `:to` or `:from`, depending if the character
    is moving `:to` the room, or moving `:from` the room
  - `reason` is what will be sent to other characters in the room and displayed (to players)
  - `room_id` is the room the event is intended for
  """
  @type t() :: %__MODULE__{}
end

defmodule Kalevala.Event.Movement.Voting do
  @moduledoc """
  A voting event tracks the state of a character wishing to change rooms
  """

  defstruct [:state, :character, :to, :from, :exit_name, :reason]

  @typedoc """
  An event to allow for rooms to abort or commit the character moving.

  Each room has a chance to reject movement

  - `state` is an enum, one of the following atoms: `:request`, `:commit`, or `:abort`
  - `character` is the character performing the action
  - `to` is the room the character is going towards
  - `from` is the room the character is going away from
  - `exit_name` is the name of the exit_name that the player is using
  - `reason` is an atom such as `:no_exit` for why the movement is aborted
  """
  @type t() :: %__MODULE__{}
end

defmodule Kalevala.Event.Movement.Request do
  @moduledoc """
  Character requesting to move from their current room in a exit_name

  A move request transitions through several stages before commiting or aborting.

  The character requests the room to move in a exit_name.

  ```
  %Move.Request{
    character: character,
    exit_name: "north"
  }
  ```

  The room process sends a voting event to the Zone after determining that there is
  a valid exit in this exit_name.

  ```
  %Move.Voting{
    state: :request,
    character: character,
    from: start_room_id,
    to: end_room_id,
    exit_name: "north"
  }
  ```

  The zone then asks the `to` and `from` room if they are OK with the character moving. Each
  room will be `GenServer.call`ed to block and keep this synchronous. The room `movement/2`
  callback will be called for each room, so they can vote on the movement.

  `commit` - After both room's agree that the player can move, the zone sends this event to
  the character.

  ```
  %Move.Voting{
    state: :commit,
    character: character,
    from: start_room_id,
    to: end_room_id,
    exit_name: "north"
  }
  ```

  `abort` - If either room rejects the movement, the zone will respond with an abort.

  ```
  %Move.Voting{
    state: :abort,
    character: character,
    from: start_room_id,
    to: end_room_id,
    exit_name: "north",
    reason: :door_locked
  }

  %Move.Voting{
    state: :abort,
    character: character,
    from: start_room_id,
    exit_name: "north",
    reason: :no_exit
  }
  ```

  On a commit, the player leaves the old room, and enters the new one.

  ```
  %Move{
    character: character,
    direction: :to,
    reason: "Player enters from the south."
  }

  %Move{
    character: character,
    direction: :from,
    reason: "Player leaves to the north."
  }
  ```
  """

  defstruct [:character, :exit_name]

  @typedoc """
  Signal that a character wishes to move to another location

  - `character` is the character moving
  - `exit` is the exit_name of the exit the player wants to move
  """
  @type t() :: %__MODULE__{}
end

defmodule Kalevala.Event do
  @moduledoc """
  An internal event
  """

  @type t() :: %__MODULE__{}

  @type movement_request() :: %__MODULE__.Movement.Request{}

  @type movement_voting() :: %__MODULE__.Movement.Voting{}

  @type topic() :: String.t()

  defstruct [:from_pid, :topic, :data]

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Conn
    end
  end
end

defmodule Kalevala.Event.Display do
  @moduledoc """
  An event to display text/data back to the user
  """

  defstruct lines: [], options: []
end

defmodule Kalevala.Event.CharacterUpdate do
  @moduledoc """
  Update the character in local lists
  """

  defstruct [:character]
end
