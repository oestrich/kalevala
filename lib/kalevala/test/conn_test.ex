defmodule Kalevala.ConnTest do
  @moduledoc """
  Test helpers for testing Controllers/Commands/Actions/etc
  """

  @doc """
  Generate an event struct
  """
  def build_event(character, topic, data) do
    %Kalevala.Event{
      acting_character: character,
      from_pid: self(),
      topic: topic,
      data: data
    }
  end

  @doc """
  Build a simple conn struct for the character
  """
  def build_conn(character, session \\ %{}) do
    %Kalevala.Character.Conn{
      character: character,
      session: session,
      private: %Kalevala.Character.Conn.Private{
        request_id: Kalevala.Character.Conn.Private.generate_request_id()
      }
    }
  end

  @doc """
  Refresh the conn struct for the character

  Copies out an updated character and the session
  """
  def refresh_conn(conn) do
    %Kalevala.Character.Conn{
      character: Kalevala.Character.Conn.character(conn),
      session: conn.session,
      private: %Kalevala.Character.Conn.Private{
        request_id: Kalevala.Character.Conn.Private.generate_request_id()
      }
    }
  end

  @doc """
  Assert the expected actions match the actions stored in the conn

  This expects the order to match and have no extra actions in the `actual_actions`.
  """
  defmacro assert_actions(conn, expected_actions) do
    quote do
      actual_actions = unquote(conn).private.actions

      assert length(actual_actions) == length(unquote(expected_actions))

      unquote(expected_actions)
      |> Enum.with_index()
      |> Enum.map(fn {expected_action, index} ->
        attributes = [:delay, :params, :type]
        actual_action = Enum.at(actual_actions, index)
        assert Map.take(actual_action, attributes) == Map.take(expected_action, attributes)
      end)
    end
  end

  def process_output(conn, processors) do
    output =
      Enum.map(conn.output, fn
        %Kalevala.Character.Conn.EventText{text: text} ->
          Enum.reduce(processors, text.data, fn processor, text ->
            Kalevala.Output.process(text, processor)
          end)

        %Kalevala.Character.Conn.Text{data: text} ->
          Enum.reduce(processors, text, fn processor, text ->
            Kalevala.Output.process(text, processor)
          end)
      end)

    Enum.join(output, "")
  end
end
