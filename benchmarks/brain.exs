alias Kalevala.Character.Brain.FirstSelector
alias Kalevala.Character.Brain.Sequence
alias Kalevala.Character.Brain.ConditionalSelector
alias Kalevala.Character.Brain.Condition
alias Kalevala.Character.Brain.Node
alias Kalevala.Character
alias Kalevala.Character.Conn

defmodule Kantele.Character.DelayEventAction do
  @moduledoc """
  Delay an event
  """

  use Kalevala.Character.Action

  @impl true
  def run(conn, params) do
    minimum_delay = Map.get(params, "minimum_delay", 0)
    random_delay = Map.get(params, "random_delay", 0)
    delay = minimum_delay + Enum.random(0..random_delay)

    data =
      params
      |> Map.get("data", %{})
      |> Enum.into(%{}, fn {key, value} ->
        {String.to_atom(key), value}
      end)

    delay_event(conn, delay, params["topic"], data)
  end
end

defmodule Kantele.Character.EmoteAction do
  @moduledoc """
  Action to emote in a channel (e.g. a room)
  """

  use Kalevala.Character.Action

  alias Kantele.Character.EmoteView

  @impl true
  def run(conn, params) do
    conn
    |> assign(:text, params["text"])
    |> render(EmoteView, "echo")
    |> publish_emote(params["channel_name"], params["text"], [], &publish_error/2)
  end

  def publish_error(conn, _error), do: conn
end

defmodule Kantele.Character.FleeAction do
  @moduledoc """
  Action to emote in a channel (e.g. a room)
  """

  use Kalevala.Character.Action

  @impl true
  def run(conn, _data) do
    conn
    |> event("room/flee")
    |> assign(:prompt, false)
  end

  def publish_error(conn, _error), do: conn
end

defmodule Kantele.Character.SayAction do
  @moduledoc """
  Action to speak in a channel (e.g. a room)
  """

  use Kalevala.Character.Action

  alias Kantele.Character.SayView

  @impl true
  def run(conn, params) do
    conn
    |> assign(:text, params["text"])
    |> render(SayView, "echo")
    |> publish_message(params["channel_name"], params["text"], [], &publish_error/2)
  end

  def publish_error(conn, _error), do: conn
end

brain = %Sequence{
  nodes: [
    %FirstSelector{
      nodes: [
        %ConditionalSelector{
          nodes: [
            %Condition{
              type: Kalevala.Character.Conditions.MessageMatch,
              data: %{
                self_trigger: false,
                text: ~r/\bhi\b/i
              }
            },
            %Sequence{
              nodes: [
                %Kalevala.Character.Brain.Action{
                  type: Kantele.Character.SayAction,
                  data: %{
                    channel_name: "${channel_name}",
                    text: "Hello, ${character.name}!"
                  },
                  delay: 500
                },
                %Kalevala.Character.Brain.Action{
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
              type: Kalevala.Character.Conditions.MessageMatch,
              data: %{
                self_trigger: false,
                text: ~r/\bgoblin\b/i
              }
            },
            %Kalevala.Character.Brain.Action{
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
          type: Kalevala.Character.Conditions.MessageMatch,
          data: %{
            self_trigger: false,
            text: ~r/\bboo\b/i
          }
        },
        %Kalevala.Character.Brain.Action{
          type: Kantele.Character.EmoteAction,
          data: %{
            channel_name: "${channel_name}",
            text: "hides behind a desk"
          }
        },
        %Kalevala.Character.Brain.Action{
          type: Kantele.Character.FleeAction,
          data: %{},
          delay: 0
        }
      ]
    },
    %ConditionalSelector{
      nodes: [
        %Kalevala.Character.Brain.Condition{
          type: Kalevala.Character.Conditions.EventMatch,
          data: %{
            self_trigger: false,
            topic: Kalevala.Event.Movement.Notice,
            data: %{
              direction: :to
            }
          }
        },
        %Kalevala.Character.Brain.Action{
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
        %Kalevala.Character.Brain.Condition{
          type: Kalevala.Character.Conditions.EventMatch,
          data: %{
            self_trigger: false,
            topic: "characters/emote",
            data: %{
              id: "looking"
            }
          }
        },
        %Kalevala.Character.Brain.Action{
          type: Kantele.Character.EmoteAction,
          data: %{
            channel_name: "${channel_name}",
            text: "${message}"
          }
        },
        %Kalevala.Character.Brain.Action{
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
        %Kalevala.Character.Brain.Condition{
          type: Kalevala.Character.Conditions.EventMatch,
          data: %{
            self_trigger: false,
            topic: "characters/move",
            data: %{
              id: "flee"
            }
          }
        },
        %Kalevala.Character.Brain.Action{
          type: Kantele.Character.EmoteAction,
          data: %{
            channel_name: "${channel_name}",
            text: "${message}"
          }
        },
        %Kalevala.Character.Brain.Action{
          type: Kantele.Character.FleeAction,
          data: %{},
          delay: 0
        },
        %Kalevala.Character.Brain.Action{
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
})
