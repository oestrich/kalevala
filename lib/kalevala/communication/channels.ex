defmodule Kalevala.Communication.Channels do
  @moduledoc """
  DynamicSupervisor for registering channels
  """

  use DynamicSupervisor

  alias Kalevala.Communication.Channel

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  def start_child(pid, channel_name, callback_module, options) do
    DynamicSupervisor.start_child(pid, {Channel, {channel_name, callback_module, options}})
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
