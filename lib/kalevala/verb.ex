defmodule Kalevala.Verb.Conditions do
  @moduledoc """
  A verb is not allowed unless all conditions are met

  - `location` is an array of all allowed locations, one must match
  """

  @derive Jason.Encoder
  defstruct [:location]
end

defmodule Kalevala.Verb.Context do
  @moduledoc """
  Context for running a verb

  - `location` where the verb is taking place
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

  @doc """
  Check if a list of verbs contains a verb that matches the context
  """
  def has_matching_verb?(verbs, verb_key, context) do
    verb =
      Enum.find(verbs, fn verb ->
        verb.key == verb_key
      end)

    case verb != nil do
      true ->
        matches?(verb, context)

      false ->
        false
    end
  end

  @doc """
  Check if a verb matches the context
  """
  def matches?(verb, context) do
    matches_location?(verb.conditions, context)
  end

  @doc """
  Check if the location condition matches the context

  No location condition == all locations are good

      iex> Verb.matches_location?(%{location: ["room"]}, %{location: "room"})
      true

      iex> Verb.matches_location?(%{location: ["inventory/self"]}, %{location: "inventory/self"})
      true

      iex> Verb.matches_location?(%{location: ["inventory"]}, %{location: "inventory/self"})
      true
  """
  def matches_location?(%{location: locations}, context) do
    Enum.any?(locations, fn location ->
      String.starts_with?(context.location, location)
    end)
  end

  def matches_location?(_conditions, _context), do: true
end
