defmodule Kalevala.Websocket.Handler do
  @moduledoc """
  Cowboy websocket handler

  Starts a foreman process tied to this websocket connection
  """

  @behaviour :cowboy_websocket

  alias Kalevala.Character.Conn.Lines
  alias Kalevala.Character.Foreman
  alias Kalevala.Output

  defstruct [:foreman_pid, :foreman_options, options: %{}, output_processors: []]

  @impl true
  def init(req, options) do
    handler_options = Enum.into(options.handler, %{})

    state = %__MODULE__{
      foreman_pid: nil,
      foreman_options: options.foreman,
      options: %{newline: false},
      output_processors: handler_options.output_processors
    }

    {:cowboy_websocket, req, state}
  end

  @impl true
  def websocket_init(state) do
    {:ok, foreman_pid} = Foreman.start_player(self(), state.foreman_options)

    {:ok, %{state | foreman_pid: foreman_pid}}
  end

  @impl true
  def websocket_handle({:text, text}, state) do
    case Jason.decode(text) do
      {:ok, json} ->
        handle_in(json, state)

      :error ->
        {:reply, {:text, "oops"}, state}
    end
  end

  def websocket_handle({:ping, message}, state) do
    {:reply, {:pong, message}, state}
  end

  @impl true
  def websocket_info({:send, data}, state) do
    context = %{
      lines: [],
      newline: state.options.newline,
      output_processors: state.output_processors
    }

    data = List.wrap(data)

    context =
      Enum.reduce(data, context, fn datum, context ->
        process_datum(context, datum)
      end)

    event =
      Jason.encode!(%{
        "type" => "system/multiple",
        "data" => context.lines
      })

    {:reply, {:text, event}, update_newline(state, context.newline)}
  end

  def websocket_info(:terminate, state) do
    {:stop, state}
  end

  def websocket_info(_message, state) do
    {:ok, state}
  end

  @impl true
  def terminate(_reason, _req, state) do
    send(state.foreman_pid, :terminate)

    :ok
  end

  def handle_in(%{"type" => "system/ping"}, state) do
    {:reply, {:text, Jason.encode!(%{"type" => "system/pong"})}, state}
  end

  def handle_in(%{"type" => "system/send", "data" => %{"text" => string}}, state) do
    send(state.foreman_pid, {:recv, :text, string})

    {:ok, state}
  end

  def handle_in(event, state) do
    {:reply, {:text, Jason.encode!(event)}, state}
  end

  defp process_datum(context, %Lines{data: text, newline: newline}) do
    text =
      Enum.reduce(context.output_processors, text, fn processor, text ->
        Output.process(text, processor)
      end)

    case context.newline do
      true ->
        lines = [%{"type" => "system/display", "data" => ["\n", text]}]
        %{context | lines: context.lines ++ lines, newline: newline}

      false ->
        lines = [%{"type" => "system/display", "data" => text}]
        %{context | lines: context.lines ++ lines, newline: newline}
    end
  end

  defp process_datum(context, _event), do: context

  defp update_newline(state, status) do
    %{state | options: %{state.options | newline: status}}
  end
end
