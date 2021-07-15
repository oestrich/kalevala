defmodule Kantele.ConnTest do
  @moduledoc false

  alias Kantele.Brain

  def process_output(conn) do
    processors = [
      Kalevala.Output.Tags,
      Kalevala.Output.Tables,
      Kalevala.Output.StripTags
    ]

    Kalevala.ConnTest.process_output(conn, processors)
  end

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
      import Kalevala.Character.Conn
      import Kalevala.ConnTest
      import Kantele.ConnTest
    end
  end
end
