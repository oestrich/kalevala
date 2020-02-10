defmodule Sampo.Presence do
  @moduledoc false

  use Kalevala.Presence

  @impl true
  def online(_character), do: :ok

  @impl true
  def offline(_character), do: :ok
end
