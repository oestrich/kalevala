defmodule Kantele.CharacterChannelTest do
  use ExUnit.Case

  alias Kantele.CharacterChannel

  describe "attempting to subscribe" do
    test "the character who registered it is allowed" do
      options = [character: %Kalevala.Character{id: "id"}]
      config = [character_id: "id"]

      assert :ok == CharacterChannel.subscribe_request("characters:id", options, config)
    end

    test "blocks anyone else" do
      options = [character: %Kalevala.Character{id: "new"}]
      config = [character_id: "id"]

      assert {:error, :not_allowed} ==
               CharacterChannel.subscribe_request("characters:id", options, config)
    end
  end

  describe "attempting to unsubscribe" do
    test "the character who registered it is allowed" do
      options = [character: %Kalevala.Character{id: "id"}]
      config = [character_id: "id"]

      assert :ok == CharacterChannel.unsubscribe_request("characters:id", options, config)
    end

    test "blocks anyone else" do
      options = [character: %Kalevala.Character{id: "new"}]
      config = [character_id: "id"]

      assert {:error, :not_allowed} ==
               CharacterChannel.unsubscribe_request("characters:id", options, config)
    end
  end

  describe "attempting to publish" do
    test "the character who registered it is allowed" do
      event = %Kalevala.Event{topic: Kalevala.Event.Message}
      options = [character: %Kalevala.Character{id: "id"}]
      config = [character_id: "id"]

      assert {:error, :yourself} ==
               CharacterChannel.publish_request("characters:id", event, options, config)
    end

    test "blocks anyone else" do
      event = %Kalevala.Event{topic: Kalevala.Event.Message}
      options = [character: %Kalevala.Character{id: "new"}]
      config = [character_id: "id"]

      assert :ok == CharacterChannel.publish_request("characters:id", event, options, config)
    end
  end
end
