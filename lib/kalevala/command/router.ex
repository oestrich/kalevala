defmodule Kalevala.Command.Router do
  @moduledoc """
  Parse player input and match against known patterns
  """

  alias Kalevala.Conn

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Command.Router
    end
  end

  @typedoc "Parsed params for a command"
  @type params() :: map()

  @typedoc "Route tuple"
  @type command() :: {String.t(), String.t(), atom()}

  @doc """
  Parse an input string with the conn as the context
  """
  @callback call(conn :: Conn.t(), text :: String.t()) :: :ok

  @doc """
  Parse an input string into matching route and params
  """
  @callback parse(text :: String.t()) ::
              {:ok, {route :: String.t(), params()}} | {:error, :unknown}

  @doc """
  Return a list of all commands
  """
  @callback commands() :: [command()]

  @doc """
  Pattern match the route and run the command
  """
  @callback recv(route :: String.t(), params()) :: map()

  @doc false
  def call(module, conn, text) do
    case module.parse(text) do
      {:ok, {route, params}} ->
        conn = Map.put(conn, :params, params)
        module.recv(route, conn)

      {:error, :unknown} ->
        {:error, :unknown}
    end
  end

  @doc false
  def parse(patterns, text) do
    text = String.trim(text)

    match =
      Enum.find_value(patterns, fn pattern ->
        case match_pattern(pattern, text) do
          nil ->
            false

          captures ->
            {pattern, captures}
        end
      end)

    case match != nil do
      true ->
        {:ok, match}

      false ->
        {:error, :unknown}
    end
  end

  defp match_pattern(pattern, text) do
    pattern =
      pattern
      |> String.split(" ")
      |> Enum.map(fn
        ":" <> var ->
          "(?<#{var}>.*)"

        segment ->
          segment
      end)
      |> Enum.join(" ")

    pattern = "^" <> pattern <> "$"

    pattern
    |> Regex.compile!()
    |> Regex.named_captures(text)
  end

  @doc """
  Macro to generate the receive functions

      scope(App.Commands) do
        module(Help) do
          command("help", :base)
          command("help :topic", :topic)
        end
      end
  """
  defmacro scope(module, opts) do
    quote do
      Module.register_attribute(__MODULE__, :patterns, accumulate: true)
      Module.register_attribute(__MODULE__, :commands, accumulate: true)

      unquote(parse_modules(module, opts[:do]))

      @behaviour Kalevala.Command.Router

      @impl true
      def call(conn, text) do
        Kalevala.Command.Router.call(__MODULE__, conn, text)
      end

      @impl true
      def commands() do
        Enum.sort(@commands)
      end

      @impl true
      def parse(text) do
        Kalevala.Command.Router.parse(@patterns, text)
      end

      defoverridable parse: 1, recv: 2
    end
  end

  @doc false
  def parse_modules({:__aliases__, _, top_module}, {:__block__, [], modules}) do
    Enum.map(modules, fn module ->
      parse_module(top_module, module)
    end)
  end

  def parse_modules({:__aliases__, _, top_module}, {:module, opts, args}) do
    parse_module(top_module, {:module, opts, args})
  end

  @doc false
  def parse_module(top_module, {:module, _, args}) do
    [module, args] = args
    module = {:__aliases__, elem(module, 1), top_module ++ elem(module, 2)}

    parse_commands(module, args[:do])
  end

  def parse_module(_top_module, _) do
    raise "Unknown function encountered"
  end

  @doc false
  def parse_commands(module, {:__block__, [], commands}) do
    Enum.map(commands, fn command ->
      parse_command(module, command)
    end)
  end

  def parse_commands(module, {:command, opts, args}) do
    parse_command(module, {:command, opts, args})
  end

  @doc false
  def parse_command(module, {:command, _, args}) do
    [pattern, fun, opts] = parse_command_args(args)

    quote do
      @patterns unquote(pattern)
      @commands {unquote(module), unquote(pattern), unquote(fun), unquote(opts)}

      @impl true
      def recv(unquote(pattern), conn) do
        unquote(module).unquote(fun)(conn, conn.params)
      end
    end
  end

  def parse_command(_module, _) do
    raise "Unknown function encountered"
  end

  defp parse_command_args([pattern, fun]), do: [pattern, fun, []]

  defp parse_command_args([pattern, fun, opts]), do: [pattern, fun, opts]
end
