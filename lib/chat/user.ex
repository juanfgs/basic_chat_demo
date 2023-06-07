defmodule Chat.User do
  @moduledoc """
  This handles the users for our chat
  """

  defstruct [:name, :ip, role: :user]
  @enforce_keys [:name, :ip, :role]

  @type t :: %__MODULE__{}

  @spec new(keyword()) :: t()

  def new(opts)

  def new(name: name, ip: ip, role: role) do
    {:ok, %__MODULE__{name: name, ip: ip, role: role}}
  end

  def new(name: name, ip: ip) do
    {:ok, %__MODULE__{name: name, ip: ip}}
  end
end
