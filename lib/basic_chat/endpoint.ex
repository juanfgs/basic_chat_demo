defmodule BasicChat.Endpoint do
  import Plug.Conn

  def init(options) do
    options
  end


  def call(conn, _opts) do

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{"message" => "Hello World!"}))
  end
end
