defmodule Sampo.Character do
  @moduledoc """
  Character callbacks for Kalevala
  """

  @behaviour Kalevala.Character

  @impl true
  def trim_meta(meta) do
    Map.take(meta, [:vitals])
  end
end

defmodule Sampo.Character.Meta do
  @moduledoc """
  Specific metadata for a character in Sampo
  """

  defstruct [:vitals]
end

defmodule Sampo.Character.Vitals do
  @moduledoc """
  Character vital information
  """

  @derive Jason.Encoder
  defstruct [:health_points, :max_health_points]
end
