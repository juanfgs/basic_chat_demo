defmodule BasicChat.Chat do
  @moduledoc """
  This is the server for our chat
  """
  alias BasicChat.Chat.Message
  alias BasicChat.Chat.State
  alias BasicChat.Chat.User

  use GenServer

  @type server_state :: BasicChat.Chat.State.t()
  @type initial_arguments :: %{timeout: pos_integer()}
  @spec start_link(initial_arguments()) :: {:ok, pid()} | {:error, atom}

  @default_args %{timeout: :infinity}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @spec register_user(pid(), keyword()) :: {:ok, any} | {:error, atom}
  def register_user(pid, user) do
    GenServer.call(pid, {:register_user, user})
  end

  @spec register_user(pid(), keyword()) :: {:ok, any} | {:error, atom}
  def unregister_user(pid, user) do
    GenServer.call(pid, {:unregister_user, user})
  end

  @spec get_messages(pid(), User.t() | nil) :: {:ok, list(any)} | {:error, atom}

  def get_messages(pid, user \\ nil)

  def get_messages(pid, nil) do
    GenServer.call(pid, :get_messages)
  end

  def get_messages(pid, user) do
    GenServer.call(pid, {:get_messages, user})
  end

  @spec send_message(pid(), User.t(), String.t(), User.t() | nil) :: {:ok} | {:error, atom}
  def send_message(pid, user, message, recipient \\ nil)

  def send_message(pid, user, message, nil) do
    GenServer.call(pid, {:send_message, user, message})
  end

  def send_message(pid, user, message, recipient) do
    GenServer.call(pid, {:send_message, user, message, recipient})
  end

  # Server Callbacks
  @spec init(initial_arguments()) :: {:ok, server_state, any} | {:stop, any}
  def init(args \\ @default_args) do
    {:ok, state} = State.new(args)
    {:ok, state, args[:timeout]}
  end

  def handle_call(
        {:register_user, user_data},
        _from,
        state
      ) do
    try do
      {:ok, user} = User.new(user_data)

      case State.register_user(state, user) do
        {:ok, new_state} ->
          {:reply, {:ok, user}, new_state, state.settings.timeout}

        {:error, reason} ->
          {:reply, {:error, reason}, state, state.settings.timeout}
      end
    rescue
      FunctionClauseError -> {:reply, {:error, :invalid_arguments}, state, state.settings.timeout}
    end
  end

  def handle_call(
        {:unregister_user, user_data},
        _from,
        state
      ) do
    try do
      {:ok, user} = User.new(user_data)

      case State.unregister_user(state, user) do
        {:ok, new_state} ->
          {:reply, :ok, new_state, state.settings.timeout}

        {:error, reason} ->
          {:reply, {:error, reason}, state, state.settings.timeout}
      end
    rescue
      FunctionClauseError -> {:reply, {:error, :invalid_arguments}, state, state.settings.timeout}
    end
  end

  def handle_call(:get_messages, _from, state) do
    {:reply, {:ok, [messages: State.get_messages(state)]}, state, state.settings.timeout}
  end

  def handle_call({:get_messages, user}, _from, state) do
    {:reply, {:ok, [messages: State.get_messages(state, user)]}, state, state.settings.timeout}
  end

  def handle_call({:send_message, user, msg}, _from, state) do
    case State.append_message(state, user, msg) do
      {:ok, new_state} ->
        {:reply, :ok, new_state, new_state.settings.timeout}

      {:error, reason} ->
        {:reply, {:error, reason}, state, state.settings.timeout}
    end
  end

  def handle_call({:send_message, user, msg, recipient}, _from, state) do
    case State.append_message(state, user, msg, recipient) do
      {:ok, new_state} ->
        {:reply, :ok, new_state, new_state.settings.timeout}

      {:error, reason} ->
        {:reply, {:error, reason}, state, state.settings.timeout}
    end
  end
end
