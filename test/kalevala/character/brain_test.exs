defmodule Kalevala.Character.Brain.VariableTest do
  use ExUnit.Case

  alias Kalevala.Character.Brain.Variable

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

      {:ok, data} = Variable.replace(data, event_data)

      assert data[:channel_name] == "general"
    end

    test "multiple variables" do
      event_data = %{
        channel_name: "general",
        text: "Hello!"
      }

      data = %{
        text: "[${channel_name}] ${text}"
      }

      {:ok, data} = Variable.replace(data, event_data)

      assert data[:text] == "[general] Hello!"
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

      {:ok, data} = Variable.replace(data, event_data)

      assert data[:text] == "How are you, Elias? Welcome to general"
    end

    test "nested data" do
      event_data = %{
        channel_name: "general",
        character: %{
          name: "Elias"
        },
        text: "Hello!"
      }

      data = %{
        channel: %{
          name: "${channel_name}"
        },
        text: "How are you, ${character.name}? Welcome to ${channel_name}"
      }

      {:ok, data} = Variable.replace(data, event_data)

      assert data[:text] == "How are you, Elias? Welcome to general"
    end

    test "values that aren't strings" do
      event_data = %{
        channel_name: "general",
        character: %{
          name: "Elias"
        },
        text: "Hello!"
      }

      data = %{
        text: "How are you, ${character.name}? Welcome to ${channel_name}",
        other: 10
      }

      {:ok, data} = Variable.replace(data, event_data)

      assert data[:text] == "How are you, Elias? Welcome to general"
    end

    test "missing values" do
      event_data = %{
        character: %{
          status: "a person"
        }
      }

      data = %{
        channel: %{
          name: "${channel.name}"
        },
        text: "How are you, ${character.name}? Welcome to ${channel_name}"
      }

      :error = Variable.replace(data, event_data)
    end
  end
end
