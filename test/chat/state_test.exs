defmodule Chat.StateTest do
  use ExUnit.Case
  doctest Chat.State
  alias Chat.User

  describe "new/1" do
    test "it creates a new state with given information" do
      assert {:ok, %Chat.State{users: [], messages: [], settings: [timeout: 50]}} =
               Chat.State.new(timeout: 50)
    end
  end

  describe "username_exists?/2" do
    test "it returns true if a given user exists in the state" do
      assert %Chat.State{users: [%User{name: "Pepito", ip: "127.0.0.1", role: :admin}]}
             |> Chat.State.username_exists?("Pepito") == true
    end
  end

  describe "append_message/2" do
    setup do
      [state: %Chat.State{users: [%User{name: "Pepito", ip: "127.0.0.1", role: :admin}]}]
    end

    test "it appends the message to the message collection", %{
      state: %Chat.State{users: [user]} = state
    } do
      {:ok, state} = Chat.State.append_message(state, user, "I live Again!!")
      assert List.first(state.messages).message == "I live Again!!" 
    end
  end
end
