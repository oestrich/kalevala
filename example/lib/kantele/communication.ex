defmodule Kantele.Communication.BroadcastChannel do
  use Kalevala.Communication.Channel
end

defmodule Kantele.Communication do
  use Kalevala.Communication

  @impl true
  def initial_channels() do
    [{"general", Kantele.Communication.BroadcastChannel, []}]
  end
end
