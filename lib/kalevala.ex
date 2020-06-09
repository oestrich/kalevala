defmodule Kalevala do
  @moduledoc """
  Documentation for Kalevala.
  """

  alias Kalevala.Character.Foreman

  @doc """
  Get the loaded version of Kalevala
  """
  def version() do
    {:kalevala, _, version} =
      Enum.find(:application.loaded_applications(), fn {app, _, _version} ->
        app == :kalevala
      end)

    to_string(version)
  end
end
