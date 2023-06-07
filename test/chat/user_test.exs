defmodule BasicChat.Chat.UserTest do
  use ExUnit.Case
  doctest BasicChat.Chat.User

  describe "new/3" do
    test "it creates a new user with given information" do
      assert {:ok, %BasicChat.Chat.User{name: "Juan", ip: "127.0.0.1", role: :admin}} =
               BasicChat.Chat.User.new(name: "Juan", ip: "127.0.0.1", role: :admin)
    end
  end

  describe "new/2" do
    test 'it defaults to :user role if not provided' do
      assert {:ok, %BasicChat.Chat.User{name: "Juan", ip: "127.0.0.1", role: :admin}} =
               BasicChat.Chat.User.new(name: "Juan", ip: "127.0.0.1", role: :admin)
    end
  end
end
