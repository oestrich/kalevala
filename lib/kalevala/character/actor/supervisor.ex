defmodule Kalevala.Character.Actor.Supervisor do
  @moduledoc """
  Supervisor for actor processes
  """

  use DynamicSupervisor

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
