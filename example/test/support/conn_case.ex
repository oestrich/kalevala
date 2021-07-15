defmodule Kantele.ConnTest do
  @moduledoc false

  alias Kantele.Brain

  def process_brain(brain_name) do
    Brain.load_all()
    |> Brain.process_all()
    |> Map.get(brain_name)
  end
end

defmodule Kantele.ConnCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import Kalevala.ConnTest
      import Kantele.ConnTest
    end
  end
end
