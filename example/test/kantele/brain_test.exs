defmodule Kantele.BrainTestHelpers do
  def new_conn(character) do
    %Kalevala.Character.Conn{
      character: character,
      session: %{},
      private: %Kalevala.Character.Conn.Private{
        request_id: Kalevala.Character.Conn.Private.generate_request_id()
      }
    }
  end

  def generate_character(name, brain \\ nil) do
    %Kalevala.Character{
      id: Kalevala.Character.generate_id(),
      name: name,
      pid: self(),
      brain: brain,
      room_id: "room-id"
    }
  end

  def event(character, topic, data) do
    %Kalevala.Event{
      acting_character: character,
      from_pid: self(),
      topic: topic,
      data: data
    }
  end

  defmacro assert_actions(actual_actions, expected_actions) do
    quote do
      assert length(unquote(actual_actions)) == length(unquote(expected_actions))

      unquote(expected_actions)
      |> Enum.with_index()
      |> Enum.map(fn {expected_action, index} ->
        attributes = [:delay, :params, :type]
        actual_action = Enum.at(unquote(actual_actions), index)
        assert Map.take(actual_action, attributes) == Map.take(expected_action, attributes)
      end)
    end
  end

  defmacro assert_brain_value(brain, key, value) do
    quote do
      assert Kalevala.Brain.get(unquote(brain), unquote(key)) == unquote(value)
    end
  end
end

defmodule Kantele.BrainTest do
  use ExUnit.Case, async: true

  import Kantele.BrainTestHelpers

  alias Kalevala.Character.Conn
  alias Kantele.Brain

  @brain Brain.process_all(Brain.load_all())["town_crier"]

  describe "town crier brain" do
    setup do: %{brain: @brain}

    test "say hello", %{brain: brain} do
      character = generate_character("player")

      event =
        event(character, Kalevala.Event.Message, %Kalevala.Event.Message{
          channel_name: "rooms:room-id",
          character: character,
          id: Kalevala.Event.Message.generate_id(),
          text: "hi",
          type: "speech"
        })

      conn =
        new_conn(%Kalevala.Character{
          id: Kalevala.Character.generate_id(),
          pid: self(),
          name: "nonplayer",
          room_id: "room-id",
          brain: brain
        })

      conn = Kalevala.Brain.run(brain, conn, event)

      assert_actions(conn.private.actions, [
        %Kalevala.Character.Action{
          delay: 500,
          params: %{"channel_name" => "rooms:room-id", "text" => "Hello, player!"},
          type: Kantele.Character.SayAction
        },
        %Kalevala.Character.Action{
          delay: 750,
          params: %{"channel_name" => "rooms:room-id", "text" => "How are you?"},
          type: Kantele.Character.SayAction
        }
      ])
    end

    test "say goblin", %{brain: brain} do
      character = generate_character("player")

      event =
        event(character, Kalevala.Event.Message, %Kalevala.Event.Message{
          channel_name: "rooms:room-id",
          character: character,
          id: Kalevala.Event.Message.generate_id(),
          text: "goblin",
          type: "speech"
        })

      conn = new_conn(generate_character("nonplayer", brain))

      conn = Kalevala.Brain.run(brain, conn, event)

      assert_actions(conn.private.actions, [
        %Kalevala.Character.Action{
          delay: 0,
          params: %{"channel_name" => "rooms:room-id", "text" => "I have a quest for you."},
          type: Kantele.Character.SayAction
        }
      ])
    end

    test "say boo", %{brain: brain} do
      character = generate_character("player")

      event =
        event(character, Kalevala.Event.Message, %Kalevala.Event.Message{
          channel_name: "rooms:room-id",
          character: character,
          id: Kalevala.Event.Message.generate_id(),
          text: "boo",
          type: "speech"
        })

      conn = new_conn(generate_character("nonplayer", brain))

      conn = Kalevala.Brain.run(brain, conn, event)

      assert_actions(conn.private.actions, [
        %Kalevala.Character.Action{
          delay: 0,
          params: %{"channel_name" => "rooms:room-id", "text" => "hides behind a desk"},
          type: Kantele.Character.EmoteAction
        }
      ])

      brain = Conn.character(conn).brain
      assert_brain_value(brain, "condition-#{character.id}", "cowering")

      character2 = generate_character("player2")

      event =
        event(character, Kalevala.Event.Message, %Kalevala.Event.Message{
          channel_name: "rooms:room-id",
          character: character2,
          id: Kalevala.Event.Message.generate_id(),
          text: "boo",
          type: "speech"
        })

      conn = new_conn(generate_character("nonplayer", Conn.character(conn).brain))

      conn = Kalevala.Brain.run(brain, conn, event)

      assert_actions(conn.private.actions, [
        %Kalevala.Character.Action{
          delay: 0,
          params: %{"channel_name" => "rooms:room-id", "text" => "hides behind a desk"},
          type: Kantele.Character.EmoteAction
        }
      ])

      event =
        event(character, Kalevala.Event.Message, %Kalevala.Event.Message{
          channel_name: "rooms:room-id",
          character: character,
          id: Kalevala.Event.Message.generate_id(),
          text: "boo",
          type: "speech"
        })

      conn = new_conn(generate_character("nonplayer", Conn.character(conn).brain))

      conn = Kalevala.Brain.run(brain, conn, event)

      assert_actions(conn.private.actions, [
        %Kalevala.Character.Action{
          delay: 0,
          params: %{"channel_name" => "rooms:room-id", "text" => "*again*"},
          type: Kantele.Character.EmoteAction
        }
      ])
    end

    test "character entering", %{brain: brain} do
      character = generate_character("player")

      event =
        event(character, Kalevala.Event.Movement.Notice, %Kalevala.Event.Movement.Notice{
          character: character,
          direction: :to,
          reason: "Player enters"
        })

      conn = new_conn(generate_character("nonplayer", brain))

      conn = Kalevala.Brain.run(brain, conn, event)

      assert_actions(conn.private.actions, [
        %Kalevala.Character.Action{
          delay: 0,
          params: %{
            "channel_name" => "rooms:room-id",
            "text" => "Welcome, player!",
            "delay" => 500
          },
          type: Kantele.Character.SayAction
        }
      ])
    end

    test "ticking emote", %{brain: brain} do
      character = generate_character("nonplayer", brain)

      event =
        event(character, "characters/emote", %{
          id: "looking",
          message: "looks around for someone to talk to."
        })

      conn = new_conn(character)

      conn = Kalevala.Brain.run(brain, conn, event)

      assert_actions(conn.private.actions, [
        %Kalevala.Character.Action{
          delay: 0,
          params: %{
            "channel_name" => "rooms:room-id",
            "text" => "looks around for someone to talk to."
          },
          type: Kantele.Character.EmoteAction
        },
        %Kalevala.Character.Action{
          delay: 0,
          params: %{
            "data" => %{"id" => "looking", "message" => "looks around for someone to talk to."},
            "minimum_delay" => 90_000,
            "random_delay" => 180_000,
            "topic" => "characters/emote"
          },
          type: Kantele.Character.DelayEventAction
        }
      ])
    end
  end
end
