defmodule Kalevala.World.Room.Movement do
  @moduledoc """
  Handle room movement
  """

  alias Kalevala.Event
  alias Kalevala.Event.Movement
  alias Kalevala.Event.Movement.Voting
  alias Kalevala.World.Zone

  @doc """
  Handle the movement request

  Called after `Kalevala.World.Room.movement_request/2`.

  - If an abort, forward to the character
  - Otherwise, Forward to the zone
  """
  def handle_request({:abort, event, reason}, state, metadata) do
    %{character: character} = event.data

    event = %Event{
      from_pid: self(),
      topic: Voting,
      metadata: metadata,
      data: %Voting{
        aborted: true,
        character: character,
        from: state.data.id,
        exit_name: event.data.exit_name,
        reason: reason
      }
    }

    send(character.pid, Voting.abort(event))
  end

  def handle_request({:proceed, event, room_exit}, state, metadata) do
    %{character: character} = event.data

    event = %Event{
      from_pid: self(),
      topic: Voting,
      metadata: metadata,
      data: %Voting{
        character: character,
        from: state.data.id,
        to: room_exit.end_room_id,
        exit_name: room_exit.exit_name
      }
    }

    Zone.global_name(state.data.zone_id)
    |> GenServer.whereis()
    |> send(event)
  end

  @doc """
  Handle the movement event
  """
  def handle_event(state, event = %Event{topic: Movement, data: %{direction: :to}}) do
    state
    |> broadcast(event)
    |> append_character(event)
  end

  def handle_event(state, event = %Event{topic: Movement, data: %{direction: :from}}) do
    state
    |> reject_character(event)
    |> broadcast(event)
  end

  @doc """
  Broadcast the event to characters in the room
  """
  def broadcast(state, event) do
    event = %Kalevala.Event{
      acting_character: event.data.character,
      from_pid: event.from_pid,
      topic: Kalevala.Event.Movement.Notice,
      data: %Kalevala.Event.Movement.Notice{
        character: event.data.character,
        direction: event.data.direction,
        reason: event.data.reason
      }
    }

    Enum.each(state.private.characters, fn character ->
      send(character.pid, event)
    end)

    state
  end

  defp append_character(state, event) do
    characters = [event.data.character | state.private.characters]
    private = Map.put(state.private, :characters, characters)

    Map.put(state, :private, private)
  end

  defp reject_character(state, event) do
    characters =
      Enum.reject(state.private.characters, fn character ->
        character.id == event.data.character.id
      end)

    private = Map.put(state.private, :characters, characters)
    Map.put(state, :private, private)
  end
end
