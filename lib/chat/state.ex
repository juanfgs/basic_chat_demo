defmodule Chat.State do
  defstruct users: [], messages: [], settings: []
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
end
