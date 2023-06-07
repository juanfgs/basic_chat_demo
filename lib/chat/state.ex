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

  @spec get_messages(t(), User.t()| atom) :: boolean()

  def get_messages(state, recipient \\ :all) 
  def get_messages(%__MODULE__{messages: messages}, user) do
    
    Enum.filter(messages, fn message ->
      message.recipient == user
    end)
  end



  @spec register_user(t(), User.t()) :: {:ok, t()} | {:error, atom}
  def register_user(%__MODULE__{users: users} = state, user) do
    unless username_exists?(state, user.name) do
      {:ok, %__MODULE__{state | users: [user | users]}}
    else
      {:error, :username_already_taken}
    end
  end

  @spec unregister_user(t(), User.t()) :: {:ok, t()} | {:error, atom}
  def unregister_user(%__MODULE__{users: users} = state, user) do
    if username_exists?(state, user.name) do
      filtered_users =
        Enum.reject(users, fn u ->
          u.name == user.name && u.ip == user.ip
        end)

      {:ok, %__MODULE__{state | users: filtered_users}}
    else
      {:error, :user_not_found}
    end
  end

  @spec append_message(t(), User.t(), String.t(), User.t() | atom) :: {:ok, t()} | {:error, atom}
  def append_message(%__MODULE__{messages: messages} = state, user, message, recipient \\ :all) do
    if username_exists?(state, user.name) do
      {:ok, new_message} = Message.new(user, message,recipient)
      {:ok, %__MODULE__{state | messages: [new_message | messages]}}
    else
      {:error, :unlogged_user}
    end
  end

end
