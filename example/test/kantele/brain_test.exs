defmodule Kantele.BrainTest do
  use Kantele.ConnCase, async: true

  import Kalevala.BrainTest
  import Kantele.TestHelpers

  describe "town crier brain" do
    test "say hello" do
      nonplayer = generate_character("nonplayer", process_brain("town_crier"))
      player = generate_character("player")

      event =
        build_event(player, Kalevala.Event.Message, %Kalevala.Event.Message{
          channel_name: "rooms:room-id",
          character: player,
          id: Kalevala.Event.Message.generate_id(),
          text: "hi",
          type: "speech"
        })

      conn =
        nonplayer
        |> build_conn()
        |> run_brain(event)

      assert_actions(conn, [
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

    test "say goblin" do
      nonplayer = generate_character("nonplayer", process_brain("town_crier"))
      player = generate_character("player")

      event =
        build_event(player, Kalevala.Event.Message, %Kalevala.Event.Message{
          channel_name: "rooms:room-id",
          character: player,
          id: Kalevala.Event.Message.generate_id(),
          text: "goblin",
          type: "speech"
        })

      conn =
        nonplayer
        |> build_conn()
        |> run_brain(event)

      assert_actions(conn, [
        %Kalevala.Character.Action{
          delay: 0,
          params: %{"channel_name" => "rooms:room-id", "text" => "I have a quest for you."},
          type: Kantele.Character.SayAction
        }
      ])
    end

    test "say boo" do
      nonplayer = generate_character("nonplayer", process_brain("town_crier"))
      player1 = generate_character("player")
      player2 = generate_character("player2")

      event =
        build_event(player1, Kalevala.Event.Message, %Kalevala.Event.Message{
          channel_name: "rooms:room-id",
          character: player1,
          id: Kalevala.Event.Message.generate_id(),
          text: "boo",
          type: "speech"
        })

      conn =
        nonplayer
        |> build_conn()
        |> run_brain(event)

      assert_actions(conn, [
        %Kalevala.Character.Action{
          delay: 0,
          params: %{"channel_name" => "rooms:room-id", "text" => "hides behind a desk"},
          type: Kantele.Character.EmoteAction
        }
      ])

      assert_brain_value(conn, "condition-#{player1.id}", "cowering")

      event =
        build_event(player2, Kalevala.Event.Message, %Kalevala.Event.Message{
          channel_name: "rooms:room-id",
          character: player2,
          id: Kalevala.Event.Message.generate_id(),
          text: "boo",
          type: "speech"
        })

      conn =
        conn
        |> refresh_conn()
        |> run_brain(event)

      assert_actions(conn, [
        %Kalevala.Character.Action{
          delay: 0,
          params: %{"channel_name" => "rooms:room-id", "text" => "hides behind a desk"},
          type: Kantele.Character.EmoteAction
        }
      ])

      event =
        build_event(player1, Kalevala.Event.Message, %Kalevala.Event.Message{
          channel_name: "rooms:room-id",
          character: player1,
          id: Kalevala.Event.Message.generate_id(),
          text: "boo",
          type: "speech"
        })

      conn =
        conn
        |> refresh_conn()
        |> run_brain(event)

      assert_actions(conn, [
        %Kalevala.Character.Action{
          delay: 0,
          params: %{"channel_name" => "rooms:room-id", "text" => "*again*"},
          type: Kantele.Character.EmoteAction
        }
      ])
    end

    test "character entering" do
      nonplayer = generate_character("nonplayer", process_brain("town_crier"))
      player = generate_character("player")

      event =
        build_event(player, Kalevala.Event.Movement.Notice, %Kalevala.Event.Movement.Notice{
          character: player,
          direction: :to,
          reason: "Player enters"
        })

      conn =
        nonplayer
        |> build_conn()
        |> run_brain(event)

      assert_actions(conn, [
        %Kalevala.Character.Action{
          delay: 500,
          params: %{
            "channel_name" => "rooms:room-id",
            "text" => "Welcome, player!"
          },
          type: Kantele.Character.SayAction
        }
      ])
    end

    test "ticking emote" do
      nonplayer = generate_character("nonplayer", process_brain("town_crier"))

      event =
        build_event(nonplayer, "characters/emote", %{
          id: "looking",
          message: "looks around for someone to talk to."
        })

      conn =
        nonplayer
        |> build_conn()
        |> run_brain(event)

      assert_actions(conn, [
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
