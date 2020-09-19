alias Kalevala.Brain.FirstSelector
alias Kalevala.Brain.Sequence
alias Kalevala.Brain.ConditionalSelector
alias Kalevala.Brain.Condition
alias Kalevala.Brain.Node
alias Kalevala.Character
alias Kalevala.Character.Conn

brain = %Sequence{
  nodes: [
    %FirstSelector{
      nodes: [
        %ConditionalSelector{
          nodes: [
            %Condition{
              type: Kalevala.Brain.Conditions.MessageMatch,
              data: %{
                self_trigger: false,
                interested?: fn _ -> true end,
                text: ~r/\bhi\b/i
              }
            },
            %Sequence{
              nodes: [
                %Kalevala.Brain.Action{
                  type: Kantele.Character.SayAction,
                  data: %{
                    channel_name: "${channel_name}",
                    text: "Hello, ${character.name}!"
                  },
                  delay: 500
                },
                %Kalevala.Brain.Action{
                  type: Kantele.Character.SayAction,
                  data: %{
                    channel_name: "${channel_name}",
                    text: "How are you?"
                  },
                  delay: 750
                }
              ]
            }
          ]
        },
        %ConditionalSelector{
          nodes: [
            %Condition{
              type: Kalevala.Brain.Conditions.MessageMatch,
              data: %{
                self_trigger: false,
                interested?: fn _ -> true end,
                text: ~r/\bgoblin\b/i
              }
            },
            %Kalevala.Brain.Action{
              type: Kantele.Character.SayAction,
              data: %{
                channel_name: "${channel_name}",
                text: "I have a quest for you."
              }
            }
          ]
        }
      ]
    },
    %ConditionalSelector{
      nodes: [
        %Condition{
          type: Kalevala.Brain.Conditions.MessageMatch,
          data: %{
            self_trigger: false,
            interested?: fn _ -> true end,
            text: ~r/\bboo\b/i
          }
        },
        %Kalevala.Brain.Action{
          type: Kantele.Character.EmoteAction,
          data: %{
            channel_name: "${channel_name}",
            text: "hides behind a desk"
          }
        },
        %Kalevala.Brain.Action{
          type: Kantele.Character.FleeAction,
          data: %{},
          delay: 0
        }
      ]
    },
    %ConditionalSelector{
      nodes: [
        %Kalevala.Brain.Condition{
          type: Kalevala.Brain.Conditions.EventMatch,
          data: %{
            self_trigger: false,
            topic: Kalevala.Event.Movement.Notice,
            data: %{
              direction: :to
            }
          }
        },
        %Kalevala.Brain.Action{
          type: Kantele.Character.SayAction,
          data: %{
            channel_name: "rooms:${room_id}",
            text: "Welcome, ${character.name}"
          }
        }
      ]
    },
    %ConditionalSelector{
      nodes: [
        %Kalevala.Brain.Condition{
          type: Kalevala.Brain.Conditions.EventMatch,
          data: %{
            self_trigger: false,
            topic: "characters/emote",
            data: %{
              id: "looking"
            }
          }
        },
        %Kalevala.Brain.Action{
          type: Kantele.Character.EmoteAction,
          data: %{
            channel_name: "${channel_name}",
            text: "${message}"
          }
        },
        %Kalevala.Brain.Action{
          type: Kantele.Character.DelayEventAction,
          data: %{
            minimum_delay: 30000,
            random_delay: 180_000,
            topic: "characters/emote",
            data: %{
              id: "${id}",
              message: "${message}"
            }
          }
        }
      ]
    },
    %ConditionalSelector{
      nodes: [
        %Kalevala.Brain.Condition{
          type: Kalevala.Brain.Conditions.EventMatch,
          data: %{
            self_trigger: false,
            topic: "characters/move",
            data: %{
              id: "flee"
            }
          }
        },
        %Kalevala.Brain.Action{
          type: Kantele.Character.EmoteAction,
          data: %{
            channel_name: "${channel_name}",
            text: "${message}"
          }
        },
        %Kalevala.Brain.Action{
          type: Kantele.Character.FleeAction,
          data: %{},
          delay: 0
        },
        %Kalevala.Brain.Action{
          type: Kantele.Character.DelayEventAction,
          data: %{
            minimum_delay: 30000,
            random_delay: 180_000,
            topic: "characters/move",
            data: %{
              id: "${id}"
            }
          }
        }
      ]
    }
  ]
}

character = %Character{
  id: Character.generate_id(),
  name: "character",
  room_id: "sammatti:town_square"
}

acting_character = %Character{
  id: Character.generate_id(),
  name: "acting_character",
  room_id: "sammatti:town_square"
}

conn = %Conn{
  character: character,
  session: %{},
  private: %Conn.Private{
    request_id: Conn.Private.generate_request_id()
  }
}

hi_event = fn ->
  event = %Kalevala.Event{
    acting_character: acting_character,
    topic: Kalevala.Event.Message,
    data: %Kalevala.Event.Message{
      channel_name: "general",
      character: acting_character,
      text: "hi"
    }
  }

  Node.run(brain, conn, event)
end

move_event = fn ->
  event = %Kalevala.Event{
    acting_character: acting_character,
    topic: Kalevala.Event.Movement.Notice,
    data: %Kalevala.Event.Movement.Notice{
      character: acting_character,
      direction: :to,
      reason: "enters"
    }
  }

  Node.run(brain, conn, event)
end

Benchee.run(%{
  "hi" => hi_event,
  "move" => move_event,
}, parallel: System.schedulers_online())
