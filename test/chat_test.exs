defmodule BasicChat.ChatTest do
  use ExUnit.Case
  doctest BasicChat.Chat
  alias BasicChat.Chat

  describe "start_link/1" do
    test "Spawns a process" do
      {:ok, pid} = Chat.start_link(%{timeout: 50})
      assert is_pid(pid)
      assert pid != self()
      assert Process.alive?(pid)
    end
  end

  describe "register_user/1" do
    setup do
      {:ok, pid} = Chat.start_link(%{timeout: :infinity})
      [pid: pid]
    end

    test "registering a user inserts it into our state with the correct data", %{pid: pid} do
      assert {:ok, user} = Chat.register_user(pid, name: "Juan", ip: "127.0.0.1", role: :admin)

      assert user.name == "Juan"
      assert user.ip == "127.0.0.1"
      assert user.role == :admin
    end

    test "missing a required key returns an error", %{pid: pid} do
      assert {:error, :invalid_arguments} = Chat.register_user(pid, name: "Juan")
    end

    test "register a user with the same name twice, returns error ", %{pid: pid} do
      assert {:ok, _user} = Chat.register_user(pid, name: "Juan", ip: "127.0.0.1", role: :admin)

      assert {:error, :username_already_taken} =
               Chat.register_user(pid, name: "Juan", ip: "127.0.0.1", role: :admin)
    end
  end

  describe "unregister_user/1" do
    setup do
      {:ok, pid} = Chat.start_link(%{timeout: :infinity})
      [pid: pid]
    end

    test "unregistered user cannot send chat", %{pid: pid} do
      {:ok, user} = Chat.register_user(pid, name: "Juan", ip: "127.0.0.1", role: :admin)
      assert :ok = Chat.unregister_user(pid, name: user.name, ip: user.ip)
      response = Chat.send_message(pid, user, "test")
      inspect(response)
    end

    test "returns not found when user doesn't exist", %{pid: pid} do
      assert {:error, :user_not_found} =
               Chat.unregister_user(pid, name: "pepe", ip: "123.234.231.213")
    end
  end

  describe "get_messages/1" do
    setup do
      {:ok, pid} = Chat.start_link(%{timeout: :infinity})
      [pid: pid]
    end

    test "it returns a list of messages ", %{pid: pid} do
      {:ok, messages} = Chat.get_messages(pid)
      assert messages == [messages: []]
    end

    test "messages will appear ordered by timestamp timestamp ", %{pid: pid} do
      {:ok, caleb} =
        pid
        |> Chat.register_user(name: "Caleb", ip: "127.0.0.1", role: :admin)

      {:ok, duke} =
        pid
        |> Chat.register_user(name: "Duke", ip: "127.0.0.1", role: :admin)

      spawn(fn ->
        ["I live again!!", "Good? bad? I'm the guy with the gun!!", "Rest in pieces"]
        |> Enum.each(fn msg ->
          :timer.sleep(:rand.uniform(250))
          Chat.send_message(pid, caleb, msg)
        end)
      end)

      spawn(fn ->
        ["I'm here to kick *** and chew bubblegum", "and I'm all out of gum", "Groovy!"]
        |> Enum.each(fn msg ->
          :timer.sleep(:rand.uniform(10))
          Chat.send_message(pid, duke, msg)
        end)
      end)

      :timer.sleep(300)
      {:ok, [messages: messages]} = Chat.get_messages(pid)

      assert NaiveDateTime.compare(
               List.first(messages).timestamp,
               List.last(messages).timestamp
             ) == :gt
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
      assert [messages: [%Chat.Message{message: "I live again!!"}]] = messages
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

  describe "send_message/4" do
    setup do
      {:ok, pid} = Chat.start_link(%{timeout: 50})
      [pid: pid]
    end

    test "sends a private message", %{pid: pid} do
      {:ok, user} =
        pid
        |> Chat.register_user(name: "Elden Ring narrator", ip: "127.0.0.1", role: :admin)

      {:ok, goldmask} =
        pid
        |> Chat.register_user(name: "Ever-glowing Goldmask", ip: "192.168.1.77", role: :user)

      {:ok, dungeater} =
        pid
        |> Chat.register_user(name: "Loathsome Dungeater", ip: "192.168.1.123", role: :user)

      Chat.send_message(pid, user, "Arise ye tarnished!!!", goldmask)
      {:ok, [messages: dungeater_messages]} = Chat.get_messages(pid, dungeater)
      {:ok, [messages: goldmask_messages]} = Chat.get_messages(pid, goldmask)
      {:ok, [messages: public_messages]} = Chat.get_messages(pid)

      assert Enum.any?(
               public_messages,
               fn message ->
                 message.message == "Arise ye tarnished!!!"
               end
             ) == false

      assert Enum.any?(
               dungeater_messages,
               fn message ->
                 message.message == "Arise ye tarnished!!!"
               end
             ) == false

      assert Enum.any?(
               goldmask_messages,
               fn message ->
                 message.message == "Arise ye tarnished!!!"
               end
             ) == true
    end
  end
end
