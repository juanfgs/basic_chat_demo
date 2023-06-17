defmodule BasicChatApi.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias BasicChat.Chat

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  post "/register" do
    case conn
         |> request()
         |> Jason.decode!() do
      %{"name" => name} ->
        ip_addr =
          conn.remote_ip
          |> :inet_parse.ntoa()
          |> to_string()

        case ChatServer
             |> Chat.register_user(name: name, ip: ip_addr) do
          {:ok, user} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Jason.encode!(user))

          {:error, reason} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(500, Jason.encode!(%{"error" => reason}))
        end
    end
  end

  post "/unregister" do
    case conn
         |> request()
         |> Jason.decode!() do
      %{"name" => name} ->
        ip_addr =
          conn.remote_ip
          |> :inet_parse.ntoa()
          |> to_string()

        case ChatServer
             |> Chat.unregister_user(name: name, ip: ip_addr) do
          {:ok} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Jason.encode!(%{success: true}))

          {:error, reason} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(500, Jason.encode!(%{"error" => reason}))
        end
    end
  end

  post "/messages" do
    case conn
         |> request()
         |> Jason.decode!() do
      %{"name" => name, "message" => message, "recipient" => recipient_name} ->
        sender =
          conn
          |> get_user(name)

        recipient =
          conn
          |> get_user(recipient_name)

        conn
        |> send_private_message(sender, message, recipient)

      %{"name" => name, "message" => message} ->
        sender =
          conn
          |> get_user(name)

        conn
        |> send_public_message(sender, message)
    end
  end

  get "/messages" do
    case ChatServer
         |> Chat.get_messages() do
      {:ok, [messages: messages]} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{messages: messages}))

      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(500, Jason.encode!(%{"error" => reason}))
    end
  end

  defp get_user(conn, name) do
    case ChatServer
         |> Chat.get_user(name) do
      {:ok, user} ->
        user

      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(500, Jason.encode!(%{"error" => reason}))
    end
  end

  defp send_private_message(conn, user, message, recipient) do
    case ChatServer
         |> Chat.send_message(user, message, recipient) do
      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(500, Jason.encode!(%{"error" => reason}))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{success: true}))
    end
  end

  defp send_public_message(conn, user, message) do
    case ChatServer
         |> Chat.send_message(user, message) do
      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(500, Jason.encode!(%{"error" => reason}))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{success: true}))
    end
  end

  defp request(conn) do
    {:ok, body, _} = conn |> Plug.Conn.read_body()
    body
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  @impl Plug.ErrorHandler

  def handle_errors(conn, %{kind: :error, reason: %Jason.DecodeError{}, stack: _stack}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(%{"error" => "bad_request"}))
  end

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack} = payload) do
    IO.inspect(payload)
    send_resp(conn, conn.status, "Something went wrong")
  end
end
