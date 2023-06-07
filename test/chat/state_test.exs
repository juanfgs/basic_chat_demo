defmodule BasicChat.Chat.StateTest do
  use ExUnit.Case
  doctest BasicChat.Chat.State
  alias BasicChat.Chat.User

  describe "new/1" do
    test "it creates a new state with given information" do
      assert {:ok, %BasicChat.Chat.State{users: [], messages: [], settings: [timeout: 50]}} =
               BasicChat.Chat.State.new(timeout: 50)
    end
  end

  describe "username_exists?/2" do
    test "it returns true if a given user exists in the state" do
      assert %BasicChat.Chat.State{users: [%User{name: "Pepito", ip: "127.0.0.1", role: :admin}]}
             |> BasicChat.Chat.State.username_exists?("Pepito") == true
    end
  end

  describe "append_message/2" do
    setup do
      [
        state: %BasicChat.Chat.State{
          users: [%User{name: "Pepito", ip: "127.0.0.1", role: :admin}]
        }
      ]
    end

    test "it appends the message to the message collection", %{
      state: %BasicChat.Chat.State{users: [user]} = state
    } do
      {:ok, state} = BasicChat.Chat.State.append_message(state, user, "I live Again!!")
      assert List.first(state.messages).message == "I live Again!!"
    end
  end
end
