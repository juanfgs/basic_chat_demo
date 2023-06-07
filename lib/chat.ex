defmodule Chat do
  @moduledoc """
  This is the server for our chat
  """
  alias Chat.Message
  alias Chat.State
  alias Chat.User

  use GenServer

  @type server_state :: Chat.State.t()
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

  @spec get_messages(pid()) :: {:ok, list(any)} | {:error, atom}
  def get_messages(pid) do
    GenServer.call(pid, :get_messages)
  end

  @spec send_message(pid(), User.t(), String.t()) :: {:ok} | {:error, atom}
  def send_message(pid, user, message) do
    GenServer.call(pid, {:send_message, user, message})
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
    {:reply, {:ok, [messages: state.messages]}, state, state.settings.timeout}
  end

  def handle_call({:send_message, user, msg}, _from, state) do
    case State.append_message(state, user, msg) do
      {:ok, new_state} ->
        {:reply, :ok, new_state, new_state.settings.timeout}

      {:error, reason} ->
        {:reply, {:error, reason}, state, state.settings.timeout}
    end
  end
end
