defmodule BasicChat.Supervisor do
  use Supervisor

  def start_link(children, opts) do
    Supervisor.start_link(__MODULE__,[children: children, opts: opts])
  end

  @impl true
  def init(children: children, opts: opts) do
    Supervisor.init(children, opts)
  end
end
