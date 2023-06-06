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
end
