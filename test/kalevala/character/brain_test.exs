defmodule Kalevala.Character.Brain.ActionTest do
  use ExUnit.Case

  alias Kalevala.Character.Brain.Action

  describe "replacing action data with event data" do
    test "simple string replacement" do
      event_data = %{
        channel_name: "general",
        text: "Hello!"
      }

      data = %{
        channel_name: "${channel_name}",
        text: "How are you?"
      }

      data = Action.replace(data, event_data)

      assert data["channel_name"] == "general"
    end

    test "multiple variables" do
      event_data = %{
        channel_name: "general",
        text: "Hello!"
      }

      data = %{
        text: "[${channel_name}] ${text}"
      }

      data = Action.replace(data, event_data)

      assert data["text"] == "[general] Hello!"
    end

    test "nested values" do
      event_data = %{
        channel_name: "general",
        character: %{
          name: "Elias"
        },
        text: "Hello!"
      }

      data = %{
        channel_name: "${channel_name}",
        text: "How are you, ${character.name}? Welcome to ${channel_name}"
      }

      data = Action.replace(data, event_data)

      assert data["text"] == "How are you, Elias? Welcome to general"
    end
  end
end
