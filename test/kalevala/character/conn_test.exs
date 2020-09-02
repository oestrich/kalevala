defmodule Kalevala.Character.ConnTest do
  use ExUnit.Case

  alias Kalevala.Character.Conn

  defmodule View do
    use Kalevala.Character.View

    def render("text", _params), do: "text"
  end

  describe "rendering text" do
    test "calls the view function and stores on the conn" do
      conn = %Conn{}

      conn = Conn.render(conn, View, "text")
      conn = Conn.render(conn, View, "text")

      assert conn.output == [
               %Kalevala.Character.Conn.Text{data: "text", newline: false},
               %Kalevala.Character.Conn.Text{data: "text", newline: false}
             ]
    end

    test "displaying a 'prompt'" do
      conn = %Conn{}

      conn = Conn.prompt(conn, View, "text")
      conn = Conn.prompt(conn, View, "text")

      assert conn.output == [
               %Kalevala.Character.Conn.Text{data: "text", newline: true},
               %Kalevala.Character.Conn.Text{data: "text", newline: true}
             ]
    end

    test "a mix of the two" do
      conn = %Conn{}

      conn = Conn.prompt(conn, View, "text")
      conn = Conn.render(conn, View, "text")

      assert conn.output == [
               %Kalevala.Character.Conn.Text{data: "text", newline: true},
               %Kalevala.Character.Conn.Text{data: "text", newline: false}
             ]
    end
  end

  describe "assigns" do
    test "assign a new value" do
      conn = %Conn{}

      conn = Conn.assign(conn, :key, "value")

      assert conn.assigns == %{key: "value"}
    end

    test "overwriting a value" do
      conn = %Conn{}

      conn = Conn.assign(conn, :key, "value")
      conn = Conn.assign(conn, :key, "updated")

      assert conn.assigns == %{key: "updated"}
    end
  end

  describe "session data" do
    test "assign a new value" do
      conn = %Conn{}

      conn = Conn.put_session(conn, :key, "value")

      assert conn.session == %{key: "value"}
    end

    test "overwriting a value" do
      conn = %Conn{}

      conn = Conn.put_session(conn, :key, "value")
      conn = Conn.put_session(conn, :key, "updated")

      assert conn.session == %{key: "updated"}
    end

    test "get a value out of the session" do
      conn = %Conn{}
      conn = Conn.put_session(conn, :key, "value")

      assert Conn.get_session(conn, :key) == "value"
    end
  end

  describe "altering private data" do
    test "setting the next controller to use for a command" do
      conn = %Conn{}

      conn = Conn.put_controller(conn, Controller)

      assert conn.private.next_controller == Controller
    end

    test "halting the conn" do
      conn = %Conn{}

      conn = Conn.halt(conn)

      assert conn.private.halt?
    end

    test "updating the character struct" do
      conn = %Conn{}

      conn = Conn.put_character(conn, %{id: :updated})

      assert conn.private.update_character == %{id: :updated}
    end
  end

  describe "channels" do
    test "subscribing" do
      conn = %Conn{}

      conn = Conn.subscribe(conn, "general", [], &error_function/1)

      [{:subscribe, "general", _opts, _err}] = conn.private.channel_changes
    end

    test "unsubscribing" do
      conn = %Conn{}

      conn = Conn.unsubscribe(conn, "general", [], &error_function/1)

      [{:unsubscribe, "general", _opts, _err}] = conn.private.channel_changes
    end

    test "publish a message" do
      conn = %Conn{}

      conn = Conn.publish_message(conn, "general", "hello", [], &error_function/1)

      [{:publish, "general", event, _opts, _err}] = conn.private.channel_changes

      assert event.topic == Kalevala.Event.Message
      assert event.data.channel_name == "general"
      assert event.data.type == "speech"
      assert event.data.text == "hello"
    end

    test "publish an emote" do
      conn = %Conn{}

      conn = Conn.publish_message(conn, "general", "hello", [type: "emote"], &error_function/1)

      [{:publish, "general", event, _opts, _err}] = conn.private.channel_changes

      assert event.topic == Kalevala.Event.Message
      assert event.data.channel_name == "general"
      assert event.data.type == "emote"
      assert event.data.text == "hello"
    end
  end

  def error_function(_err), do: :ok
end
