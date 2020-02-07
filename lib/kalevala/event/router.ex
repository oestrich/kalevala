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

      def call(conn, event) do
        call(event.topic, conn, event)
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
    [topic, fun] = args

    quote do
      @impl true
      def call(unquote(topic), conn, event) do
        unquote(module).unquote(fun)(conn, event)
      end
    end
  end

  def parse_event(_module, _) do
    raise "Unknown function encountered"
  end
end
