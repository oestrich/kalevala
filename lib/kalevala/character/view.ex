defmodule Kalevala.Character.View do
  @moduledoc """
  Render output from the game
  """

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Character.View.Macro

      alias Kalevala.Character.View
    end
  end

  @doc """
  "Join" an IO data list with a separator string

  Similar to Enum.join, but leaves as an IO data list
  """
  def join([], _separator), do: []

  def join([line], _separator), do: [line]

  def join([line | lines], separator) do
    [line, separator | join(lines, separator)]
  end

  @doc """
  Trim empty lines from io data

  Detects empty lines in io data (for example when rendered via EEx templating),
  and removes them. This way the template string works as expected, returning an
  empty string from a sub-render will strip the line.
  """
  def trim_lines([]), do: []

  def trim_lines(["\n", "", "\n" | segments]), do: ["\n" | trim_lines(segments)]

  def trim_lines(["\n", nil, "\n" | segments]), do: ["\n" | trim_lines(segments)]

  def trim_lines([segment | segments]), do: [segment | trim_lines(segments)]
end

defmodule Kalevala.Character.View.Macro do
  @moduledoc """
  Imported into views
  """

  alias Kalevala.Character.View

  @doc """
  Creates ~E which runs through EEx templating
  """
  defmacro sigil_E({:<<>>, _, [expr]}, opts) do
    string =
      EEx.compile_string(expr,
        line: __CALLER__.line + 1,
        sigil_opts: opts,
        engine: Kalevala.Character.View.EExKalevala
      )

    quote do
      View.trim_lines(unquote(string))
    end
  end

  @doc """
  Creates ~i to create IO lists that look like standard interpolation
  """
  defmacro sigil_i({:<<>>, _, text}, _) do
    Enum.map(text, &sigil_i_unwrap/1)
  end

  defp sigil_i_unwrap({:"::", _, interpolation}) do
    [text | _] = interpolation
    {_, _, [text]} = text

    quote do
      to_string(unquote(text))
    end
  end

  defp sigil_i_unwrap(text) when is_binary(text) do
    :elixir_interpolation.unescape_string(text)
  end
end

defmodule Kalevala.Character.View.EExKalevala do
  @moduledoc """
  An EEx Engine that returns IO data instead of a string

  Taken from [Phoenix.HTML.Engine](https://github.com/phoenixframework/phoenix_html/blob/master/lib/phoenix_html/engine.ex)
  """

  @behaviour EEx.Engine

  @impl true
  def init(_opts) do
    %{
      iodata: [],
      dynamic: [],
      vars_count: 0
    }
  end

  @impl true
  def handle_begin(state) do
    %{state | iodata: [], dynamic: []}
  end

  @impl true
  def handle_end(quoted) do
    handle_body(quoted)
  end

  @impl true
  def handle_body(state) do
    %{iodata: iodata, dynamic: dynamic} = state
    iodata = Enum.reverse(iodata)
    {:__block__, [], Enum.reverse([iodata | dynamic])}
  end

  @impl true
  def handle_text(state, _meta, text) do
    %{iodata: iodata} = state
    %{state | iodata: [text | iodata]}
  end

  @impl true
  def handle_expr(state, "=", ast) do
    ast = Macro.prewalk(ast, &EEx.Engine.handle_assign/1)
    %{iodata: iodata, dynamic: dynamic, vars_count: vars_count} = state
    var = Macro.var(:"arg#{vars_count}", __MODULE__)
    ast = quote do: unquote(var) = unquote(ast)
    %{state | dynamic: [ast | dynamic], iodata: [var | iodata], vars_count: vars_count + 1}
  end

  def handle_expr(state, "", ast) do
    ast = Macro.prewalk(ast, &EEx.Engine.handle_assign/1)
    %{dynamic: dynamic} = state
    %{state | dynamic: [ast | dynamic]}
  end

  def handle_expr(state, marker, ast) do
    EEx.Engine.handle_expr(state, marker, ast)
  end
end
