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
