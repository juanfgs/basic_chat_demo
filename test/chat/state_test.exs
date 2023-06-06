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
    assert  %Chat.State{users: [%User{name: "Pepito", ip: "127.0.0.1", role: :admin}]}
      |> Chat.State.username_exists?("Pepito") == true
    end
  end
end
