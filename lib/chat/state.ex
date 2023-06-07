defmodule Chat.State do
  defstruct users: [], messages: [], settings: []
  alias Chat.User
  alias Chat.Message
  @type t :: %__MODULE__{}
  @spec new(keyword()) :: t()
  def new(settings \\ []) do
    {:ok, %__MODULE__{users: [], messages: [], settings: settings}}
  end

  @spec username_exists?(t(), String.t()) :: boolean()
  def username_exists?(%__MODULE__{users: users}, name) do
    Enum.any?(users, fn user ->
      user.name == name
    end)
  end

  @spec register_user(t(), Chat.User.t()) :: {:ok, t()} | {:error, atom}
  def register_user(%__MODULE__{users: users} = state, user) do
    unless username_exists?(state, user.name) do
      {:ok, %__MODULE__{state | users: [user |  users]}}
    else
      {:error, :username_already_taken}
    end
  end

  @spec append_message(t(), Chat.User.t(), String.t()) :: {:ok, t()} | {:error, atom}
  def append_message(%__MODULE__{messages: messages} = state, user, message) do
    if username_exists?(state, user.name) do
      {:ok, new_message} = Message.new(user, message)
      {:ok, %__MODULE__{state | messages: [new_message | messages]}}
    else
      {:error, :unlogged_user}
    end
  end
end
