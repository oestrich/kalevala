defmodule Kantele.BrainTest do
  use Kantele.ConnCase, async: true

  import Kalevala.BrainTest
  import Kantele.TestHelpers

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
        build_conn(%Kalevala.Character{
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

      conn = build_conn(generate_character("nonplayer", brain))

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

      conn = build_conn(generate_character("nonplayer", brain))

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

      conn = build_conn(generate_character("nonplayer", Conn.character(conn).brain))

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

      conn = build_conn(generate_character("nonplayer", Conn.character(conn).brain))

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

      conn = build_conn(generate_character("nonplayer", brain))

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

      conn = build_conn(character)

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
