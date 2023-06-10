defmodule Kalevala.Event.Movement do
  @moduledoc """
  An event to move from one room to another
  """

  defstruct [:character, :direction, :reason, :room_id, :data]

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

defmodule Kalevala.Event.Movement.Notice do
  @moduledoc """
  Event to send a notice to other characters in the room
  """

  defstruct [:character, :direction, :reason, :data]
end

defmodule Kalevala.Event.Movement.Commit do
  @moduledoc """
  Struct for committing movement between two rooms
  """

  defstruct [:character, :to, :from, :exit_name]
end

defmodule Kalevala.Event.Movement.Abort do
  @moduledoc """
  Struct for aborting movement between two rooms
  """

  defstruct [:character, :to, :from, :exit_name, :reason]
end

defmodule Kalevala.Event.Movement.Voting do
  @moduledoc """
  A voting event tracks the state of a character wishing to change rooms

  If movement is refused, adjust `aborted` to be true to abort the event
  """

  alias Kalevala.Event
  alias Kalevala.Event.Movement.Abort
  alias Kalevala.Event.Movement.Commit

  defstruct [
    :character,
    :to,
    :from,
    :exit_name,
    :reason,
    aborted: false
  ]

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

  @doc """
  Generate a commit event after voting has occurred
  """
  def commit(event) do
    %Event{
      topic: Commit,
      metadata: event.metadata,
      data: %Commit{
        character: event.data.character,
        to: event.data.to,
        from: event.data.from,
        exit_name: event.data.exit_name
      }
    }
  end

  @doc """
  Generate an abort event after voting has occurred
  """
  def abort(event) do
    %Event{
      topic: Abort,
      metadata: event.metadata,
      data: %Abort{
        character: event.data.character,
        to: event.data.to,
        from: event.data.from,
        exit_name: event.data.exit_name,
        reason: event.data.reason
      }
    }
  end
end

defmodule Kalevala.Event.Movement.Request do
  @moduledoc """
  Character requesting to move from their current room in a exit_name

  A move request transitions through several stages before commiting or aborting.

  The character requests the room to move in a exit_name.

  ```
  %Kalevala.Event{
    topic: Kalevala.Event.Movement.Request,
    data: %Kalevala.Event.Movement.Request{
      character: character,
      exit_name: "north"
    }
  }
  ```

  The room process sends a voting event to the Zone after determining that there is
  a valid exit in this exit_name.

  ```
  %Kalevala.Event{
    topic: Kalevala.Event.Movement.Voting,
    data: %Kalevala.Event.Movement.Voting{
      character: character,
      from: start_room_id,
      to: end_room_id,
      exit_name: "north"
    }
  }
  ```

  The zone then asks the `to` and `from` room if they are OK with the character moving. Each
  room will be `GenServer.call`ed to block and keep this synchronous. The room `movement/2`
  callback will be called for each room, so they can vote on the movement. Return the event
  with `aborted: true` to reject movement.

  `Kalevala.Event.Movement.Commit` - After both room's agree that the player can move,
  the zone sends this event to the character.

  ```
  %Kalevala.Event{
    topic: Kalevala.Event.Movement.Commit,
    data: %Movement.Commit{
      character: character,
      from: start_room_id,
      to: end_room_id,
      exit_name: "north"
    }
  }
  ```

  `Kalevala.Event.Movement.Abort` - If either room rejects the movement, the zone will
  respond with an abort.

  ```
  %Kalevala.Event{
    topic: Kalevala.Event.Movement.Abort,
    data: %Kalevala.Event.Movement.Abort{
      character: character,
      from: start_room_id,
      to: end_room_id,
      exit_name: "north",
      reason: :door_locked
    }
  }

  %Kalevala.Event{
    topic: Kalevala.Event.Movement.Abort,
    data: %Kalevala.Event.Movement.Abort{
      character: character,
      from: start_room_id,
      exit_name: "north",
      reason: :no_exit
    }
  }
  ```

  On a commit, the player leaves the old room, and enters the new one.

  ```
  %Kalevala.Event{
    topic: Kalevala.Event.Movement,
    data: %Kalevala.Event.Movement{
      character: character,
      direction: :to,
      reason: "Player enters from the south."
    }
  }

  %Kalevala.Event{
    topic: Kalevala.Event.Movement,
    data: %Kalevala.Event.Movement{
      character: character,
      direction: :from,
      reason: "Player leaves to the north."
    }
  }
  ```
  """

  defstruct [:character, :exit_name, metadata: %Kalevala.Event.Metadata{}]

  @typedoc """
  Signal that a character wishes to move to another location

  - `character` is the character moving
  - `exit` is the exit_name of the exit the player wants to move
  """
  @type t() :: %__MODULE__{}
end
