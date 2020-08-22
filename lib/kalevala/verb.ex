defmodule Kalevala.Verb.Conditions do
  @moduledoc """
  A verb is not allowed unless all conditions are met

  - `location` is an array of all allowed locations, one must match
  """

  @derive Jason.Encoder
  defstruct [:location]
end

defmodule Kalevala.Verb do
  @moduledoc """
  A verb is a discrete action that the player may perform

  Things like picking up or dropping items, stealing, etc.
  """

  @derive Jason.Encoder
  defstruct [:conditions, :icon, :key, :send, :text]
end
