defmodule ChatTest do
  use ExUnit.Case
  doctest Chat

  describe "start_link/1" do
    test "Spawns a process" do
      {:ok, pid} = Chat.start_link(%{timeout: 50})
      assert is_pid(pid)
      assert pid != self()
      assert Process.alive?(pid)
    end
  end

  describe "register_user/1" do
    test "registering a user inserts it into our state" do
      {:ok, pid} = Chat.start_link(%{timeout: 50})

      assert {:ok, user} = Chat.register_user(pid, name: "Juan", ip: "127.0.0.1", role: :admin)

      assert user.name == "Juan"
      assert user.ip == "127.0.0.1"
      assert user.role == :admin
    end

    test "register a user with the same name twice, returns error " do
      {:ok, pid} = Chat.start_link(%{timeout: 50})

      assert {:ok, _user} = Chat.register_user(pid, name: "Juan", ip: "127.0.0.1", role: :admin)

      assert {:error, :username_already_taken} =
               Chat.register_user(pid, name: "Juan", ip: "127.0.0.1", role: :admin)
    end
  end

  describe "get_messages/1" do
    setup do
      {:ok, pid} = Chat.start_link(%{timeout: 50})
      [pid: pid]
    end

    test "it returns a list of messages ", %{pid: pid} do
      {:ok, messages} = Chat.get_messages(pid)
      assert messages == [messages: []]
    end
  end

  describe "send_message/3" do
    setup do
      {:ok, pid} = Chat.start_link(%{timeout: 50})
      [pid: pid]
    end

    test "Sends a message to the public chatroom", %{pid: pid} do
      {:ok, user} =
        pid
        |> Chat.register_user(name: "Caleb", ip: "127.0.0.1", role: :admin)

      Chat.send_message(pid, user, "I live again!!")
      {:ok, messages} = Chat.get_messages(pid)
      assert  [messages: [%Chat.Message{message: "I live again!!"}]] = messages
    end

    test "Messages include a reference to the author ", %{pid: pid} do
      {:ok, user} =
        pid
        |> Chat.register_user(name: "Caleb", ip: "127.0.0.1", role: :admin)

      Chat.send_message(pid, user, "I live again!!")
      {:ok, [messages: messages]} = Chat.get_messages(pid)
      assert List.first(messages).author.name == user.name
    end

    test "Messages include a timestamp ", %{pid: pid} do
      {:ok, user} =
        pid
        |> Chat.register_user(name: "Caleb", ip: "127.0.0.1", role: :admin)

      Chat.send_message(pid, user, "I live again!!")
      {:ok, [messages: messages]} = Chat.get_messages(pid)
      assert List.first(messages).timestamp != nil
    end

    test "Messages are created for all recipients by default  ", %{pid: pid} do
      {:ok, user} =
        pid
        |> Chat.register_user(name: "Caleb", ip: "127.0.0.1", role: :admin)

      Chat.send_message(pid, user, "I live again!!")
      {:ok, [messages: messages]} = Chat.get_messages(pid)
      assert List.first(messages).recipient == :all
    end
  end
end
