defmodule Kalevala.Event.Router do
  @moduledoc """
  Route in-game events

  Locates the appropriate module and function for a `Kalevala.Event`
  """

  alias Kalevala.Conn
  alias Kalevala.Event

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Event.Router, only: [scope: 2]

      @behaviour Kalevala.Event.Router

      Module.register_attribute(__MODULE__, :events, accumulate: true)

      @before_compile Kalevala.Event.Router
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def call(conn, event) do
        Enum.filter(@events, fn {topic, _module, _fun} ->
          match?(^topic, event.topic)
        end)
        |> Enum.filter(fn {topic, module, fun} ->
          call_interested?(topic, module, fun, event)
        end)
        |> Enum.reduce(conn, fn {topic, module, fun}, conn ->
          apply(module, fun, [conn, event])
        end)
      end
    end
  end

  @doc """
  Parse an input string with the conn as the context
  """
  @callback call(topic :: Event.topic(), conn :: Conn.t(), event :: Event.t()) :: :ok

  @doc """
  Macro to generate the receive functions

      scope(App) do
        module(CombatEvent) do
          event("combat/start", :start)
          event("combat/stop", :stop)
        end
      end
  """
  defmacro scope(module, opts) do
    quote do
      unquote(parse_modules(module, opts[:do]))

      @impl true
      def call(topic, _conn, _event) do
        raise "Received an unknown event - #{topic}"
      end
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

    parse_events(module, args[:do])
  end

  def parse_module(_top_module, _) do
    raise "Unknown function encountered"
  end

  @doc false
  def parse_events(module, {:__block__, [], events}) do
    Enum.map(events, fn event ->
      parse_event(module, event)
    end)
  end

  def parse_events(module, {:event, opts, args}) do
    parse_event(module, {:event, opts, args})
  end

  @doc false
  def parse_event(module, {:event, _, args}) do
    [topic, fun, options] = parse_event_args(args)

    default_interested_fun =
      quote do
        fn _event ->
          true
        end
      end

    interested_fun = Keyword.get(options, :interested?, default_interested_fun)

    quote do
      @events {unquote(topic), unquote(module), unquote(fun)}

      def call_interested?(unquote(topic), unquote(module), unquote(fun), event) do
        unquote(interested_fun).(event)
      end
    end
  end

  def parse_event(_module, _) do
    raise "Unknown function encountered"
  end

  defp parse_event_args([topic, fun]), do: [topic, fun, []]

  defp parse_event_args([topic, fun, options]), do: [topic, fun, options]
end
