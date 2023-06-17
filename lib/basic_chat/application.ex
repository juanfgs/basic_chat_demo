defmodule BasicChat.Application do
  use Application
  alias BasicChat.Chat

  @impl true
  def start(_type, _args) do
    children = [
      {Chat, [%{timeout: :infinity}, [name: ChatServer]]},
      {Plug.Cowboy, scheme: :http, plug: BasicChatApi.Router, port: 4000}
    ]

    opts = [strategy: :one_for_one, name: BasicChat.Supervisor]
    BasicChat.Supervisor.start_link(children, opts)
  end
end
