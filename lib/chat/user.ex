defmodule Chat.User do
  @moduledoc """
  This handles the users for our chat
  """

  defstruct [:name, :ip, :role]
  @enforce_keys [:name, :ip, :role]

  @type t :: %__MODULE__{}

  @spec new(String.t(), String.t(), atom()) :: t()

  def new(name, ip, role \\ :user)

  def new(name, ip, role) do
    {:ok, %__MODULE__{name: name, ip: ip, role: role}}
  end
end
