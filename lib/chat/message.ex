defmodule Chat.Message do
  alias Chat.User
  defstruct [:author, :message, :timestamp, recipient: :all]
  @enforced_keys [:author, :message, :timestamp]
  @type t :: %__MODULE__{}

  @spec new(User.t(), String.t(), atom | User.t()) :: {:ok, t()}
  def new(user, message, recipient \\ :all)

  def new(user, message, recipient) do
    {:ok,
     %__MODULE__{
       author: user,
       message: message,
       timestamp: NaiveDateTime.local_now(),
       recipient: recipient
     }}
  end
end
