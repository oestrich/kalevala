defmodule Kantele.ConnCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import Kalevala.ConnTest
    end
  end
end
