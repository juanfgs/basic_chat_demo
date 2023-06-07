defmodule Chat.UserTest do
  use ExUnit.Case
  doctest Chat.User

  describe "new/3" do
    test "it creates a new user with given information" do
      assert {:ok, %Chat.User{name: "Juan", ip: "127.0.0.1", role: :admin}} =
               Chat.User.new(name: "Juan", ip: "127.0.0.1", role: :admin)
    end
  end

  describe "new/2" do
    test 'it defaults to :user role if not provided' do
      assert {:ok, %Chat.User{name: "Juan", ip: "127.0.0.1", role: :admin}} =
               Chat.User.new(name: "Juan", ip: "127.0.0.1", role: :admin)
    end
  end
end
