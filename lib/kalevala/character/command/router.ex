defmodule Kalevala.Character.Command.DynamicCommand do
  @moduledoc """
  A parsed dynamic command

  Generated from the `dynamic` command router DSL.
  """

  @doc """
  Called when parsing text from a user

  Options are passed through from the router.
  """
  @callback parse(text :: String.t(), options :: Keyword.t()) ::
              {:dynamic, function :: atom(), params :: map()} | :skip
end

defmodule Kalevala.Character.Command.ParsedCommand do
  @moduledoc """
  A parsed command
  """

  defstruct [:module, :function, :params, :keyword_params]
end

defmodule Kalevala.Character.Command.Router do
  @moduledoc """
  Parse player input to known commands
  """

  require NimbleParsec

  alias Kalevala.Character.Command.ParsedCommand

  defmacro __using__(scope: scope) do
    {:__aliases__, _, top_module} = scope

    quote do
      import NimbleParsec
      import Kalevala.Character.Command.RouterMacros

      Module.register_attribute(__MODULE__, :parse_functions, accumulate: true)
      Module.register_attribute(__MODULE__, :aliases, accumulate: true)
      Module.register_attribute(__MODULE__, :stop_word_parsecs, accumulate: true)

      @before_compile Kalevala.Character.Command.Router

      @scope unquote(top_module)
    end
  end

  defmacro __before_compile__(env) do
    alias_functions =
      env.module
      |> Module.get_attribute(:aliases)
      |> Enum.map(fn {module, command, command_alias, fun, parse_fun} ->
        Kalevala.Character.Command.RouterMacros.generate_parse_function(
          command,
          command_alias,
          fun,
          parse_fun,
          module
        )
      end)

    stop_word_parsecs =
      env.module
      |> Module.get_attribute(:stop_word_parsecs)
      |> Enum.map(fn function ->
        stop_symbols = Module.get_attribute(env.module, function)

        case stop_symbols do
          [] ->
            quote do
              defcombinatorp(unquote(function), eos())
            end

          [stop_symbol] ->
            quote do
              defcombinatorp(unquote(function), string(unquote(stop_symbol)))
            end

          stop_symbols ->
            quote do
              defcombinatorp(
                unquote(function),
                choice(Enum.map(unquote(stop_symbols), &string/1))
              )
            end
        end
      end)

    quote do
      unquote(alias_functions)
      unquote(stop_word_parsecs)

      def call(conn, text) do
        unquote(__MODULE__).call(__MODULE__, conn, text)
      end

      @sorted_parse_functions Enum.reverse(@parse_functions)

      def parse(text) do
        unquote(__MODULE__).parse(__MODULE__, @sorted_parse_functions, text)
      end
    end
  end

  @doc false
  def call(module, conn, text) do
    case module.parse(text) do
      {:ok, %ParsedCommand{module: module, function: function, params: params}} ->
        conn = Map.put(conn, :params, params)
        apply(module, function, [conn, conn.params])

      {:error, :unknown} ->
        {:error, :unknown}
    end
  end

  @doc false
  def parse(module, parse_functions, text) do
    text = String.trim(text)

    parsed_command =
      Enum.find_value(parse_functions, fn command ->
        case apply(module, command, [text]) do
          {:ok, {module, function}, command, params} ->
            %Kalevala.Character.Command.ParsedCommand{
              module: module,
              function: function,
              keyword_params: params,
              params: process_params(params, command)
            }

          {:error, _error} ->
            false
        end
      end)

    case is_nil(parsed_command) do
      true ->
        {:error, :unknown}

      false ->
        {:ok, parsed_command}
    end
  end

  defp process_params(params, command) do
    params
    |> Enum.map(fn {key, value} ->
      {to_string(key), value}
    end)
    |> Enum.into(%{})
    |> Map.put("command", command)
  end
end

defmodule Kalevala.Character.Command.RouterMacros do
  @moduledoc """
  Set of macros to build a command router using NimbleParsec
  """

  @doc """
  Sets the `@module` tag for parse functions nested inside
  """
  defmacro module({:__aliases__, _meta, module}, do: block) do
    quote do
      @module @scope ++ unquote(module)
      unquote(block)
    end
  end

  @doc """
  Parse a new command

  `command` starts out the parse and any whitespace afterwards will be ignored
  """
  defmacro parse(command, fun, opts \\ [], parse_fun \\ nil) do
    {opts, parse_fun} = opts_vs_parse(opts, parse_fun)
    aliases = Keyword.get(opts, :aliases, [])
    parse_fun = parse_fun || (&__MODULE__.default_parse_function/1)

    aliases =
      Enum.map(aliases, fn command_alias ->
        quote do
          scope = [:"Elixir" | @module]
          module = String.to_atom(Enum.join(scope, "."))

          @aliases {module, unquote(command), unquote(command_alias), unquote(fun),
                    unquote(parse_fun)}
        end
      end)

    [
      generate_parse_function(command, command, fun, parse_fun),
      aliases
    ]
  end

  def generate_parse_function(command, command_alias, fun, parse_fun, module \\ nil) do
    internal_function_name = :"parsep_#{command_alias}_#{fun}"
    function_name = :"parse_#{command_alias}_#{fun}"
    stop_words_attribute = :"stop_symbols_#{command_alias}_#{fun}"

    module =
      module ||
        quote do
          scope = [:"Elixir" | @module]
          unquote(module) || String.to_atom(Enum.join(scope, "."))
        end

    quote do
      Module.register_attribute(__MODULE__, unquote(stop_words_attribute), accumulate: true)
      @stop_words_attribute unquote(stop_words_attribute)

      defparsecp(
        unquote(internal_function_name),
        unquote(parse_fun).(command(unquote(command_alias)))
      )

      @parse_functions unquote(function_name)
      @stop_word_parsecs unquote(stop_words_attribute)

      def unquote(function_name)(text) do
        unquote(__MODULE__).parse_text(
          unquote(module),
          unquote(fun),
          unquote(command),
          unquote(internal_function_name)(text)
        )
      end
    end
  end

  defp opts_vs_parse(opts = {:fn, _, _}, _parse_fun) do
    {[], opts}
  end

  defp opts_vs_parse(opts, parse_fun), do: {opts, parse_fun}

  def parse_text(module, fun, command, {:ok, parsed, _leftover, _unknown1, _unknown2, _unknown3}) do
    {:ok, {module, fun}, command, parsed}
  end

  def parse_text(_module, _fun, _command, {:error, error, _leftover, _u1, _u2, _u3}) do
    {:error, error}
  end

  @doc false
  # The default parse is the command only and nothing else
  def default_parse_function(command) do
    NimbleParsec.eos(command)
  end

  @doc """
  Handle dynamic parsing

  This runs the `parse/2` function on the given module at runtime. This enables
  parsing things against runtime only data.
  """
  defmacro dynamic({:__aliases__, _meta, module}, command, arguments) do
    function_name = :"parse_dynamic_#{command}"

    quote do
      @parse_functions unquote(function_name)

      def unquote(function_name)(text) do
        scope = [:"Elixir" | @scope] ++ unquote(module)
        module = String.to_atom(Enum.join(scope, "."))

        unquote(__MODULE__).parse_dynamic_text(module, unquote(arguments), text)
      end
    end
  end

  def parse_dynamic_text(module, arguments, text) do
    case module.parse(text, arguments) do
      {:dynamic, function, command, params} ->
        {:ok, {module, function}, command, params}

      :skip ->
        {:error, :unknown}
    end
  end

  @doc """
  Wraps NimbleParsec macros to generate a tagged command
  """
  defmacro command(command) do
    quote do
      string(unquote(command))
      |> label("#{unquote(command)} command")
      |> unwrap_and_tag(:command)
    end
  end

  @doc """
  Wraps NimbleParsec macros to allow for grabbing spaces

  Grabs between other pieces of the command
  """
  defmacro spaces(parsec \\ NimbleParsec.empty()) do
    quote do
      unquote(parsec)
      |> ignore(utf8_string([?\s], min: 1))
      |> label("spaces")
    end
  end

  @doc """
  Wraps NimbleParsec macros to generate a tagged word

  Words are codepoints that don't include a space, or everything inside of quotes.

  Both of the following count as a word:
  - villager
  - "town crier"
  """
  defmacro word(parsec, tag) do
    quote do
      unquote(parsec)
      |> concat(
        choice([
          ignore(string("\""))
          |> utf8_string([not: ?"], min: 1)
          |> ignore(string("\""))
          |> reduce({Enum, :join, [""]}),
          utf8_string([not: ?\s, not: ?"], min: 1)
        ])
        |> unwrap_and_tag(unquote(tag))
        |> label("#{unquote(tag)} word")
      )
    end
  end

  defmacro symbol(parsec \\ NimbleParsec.empty(), character) do
    quote do
      unquote(parsec)
      |> ignore(string(unquote(character)))
    end
  end

  @doc """
  Sets up a prepositional phrase

  Example:

      command
      |> text(:item)
      |> preposition("to", :character)
  """
  defmacro preposition(parsec \\ NimbleParsec.empty(), preposition, tag, opts \\ []) do
    {parsec, preposition, tag, opts} =
      case is_binary(parsec) do
        true ->
          {NimbleParsec.empty(), parsec, preposition, tag}

        false ->
          {parsec, preposition, tag, opts}
      end

    stop = Keyword.get(opts, :stop, default_stop_quote())

    quote do
      Module.put_attribute(__MODULE__, @stop_words_attribute, unquote(preposition))

      unquote(parsec)
      |> concat(
        ignore(string(unquote(preposition)))
        |> repeat(
          lookahead_not(unquote(stop))
          |> utf8_char([])
        )
        |> reduce({List, :to_string, []})
        |> post_traverse({Kalevala.Character.Command.RouterHelpers, :trim, []})
        |> unwrap_and_tag(unquote(tag))
      )
    end
  end

  @doc """
  Wraps NimbleParsec macros to generate tagged text

  This grabs as much as it can, or until the `stop` combinator is triggered
  """
  defmacro text(parsec, tag, opts \\ []) do
    stop = Keyword.get(opts, :stop, default_stop_quote())

    quote do
      unquote(parsec)
      |> concat(
        repeat(
          lookahead_not(unquote(stop))
          |> utf8_char([])
        )
        |> reduce({List, :to_string, []})
        |> post_traverse({Kalevala.Character.Command.RouterHelpers, :trim, []})
        |> unwrap_and_tag(unquote(tag))
      )
    end
  end

  defp default_stop_quote() do
    quote do
      parsec(@stop_words_attribute)
    end
  end
end

defmodule Kalevala.Character.Command.RouterHelpers do
  @moduledoc false

  @doc """
  Trims strings in a `text/3` parse
  """
  def trim(rest, strings, context, _line, _offset) do
    strings =
      Enum.map(strings, fn string ->
        String.trim(string)
      end)

    {rest, strings, context}
  end
end
