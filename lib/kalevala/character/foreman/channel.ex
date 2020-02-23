defmodule Kalevala.Character.Foreman.Channel do
  @moduledoc """
  Helpers for dealing with communication channels
  """

  @doc """
  Handle any channel updates from the conn
  """
  def handle_channels(conn, state) do
    Enum.reduce(conn.private.channel_changes, conn, fn channel_change, conn ->
      handle_channel_change(channel_change, conn, state)
    end)
  end

  @doc false
  def handle_channel_change({:subscribe, channel_name, options, error_fun}, conn, state) do
    case state.communication_module.subscribe(channel_name, options) do
      :ok ->
        conn

      {:error, reason} ->
        error_fun.(conn, {:error, reason})
    end
  end

  def handle_channel_change({:unsubscribe, channel_name, options, error_fun}, conn, state) do
    case state.communication_module.unsubscribe(channel_name, options) do
      :ok ->
        conn

      {:error, reason} ->
        error_fun.(conn, {:error, reason})
    end
  end

  def handle_channel_change({:publish, channel_name, event, options, error_fun}, conn, state) do
    case state.communication_module.publish(channel_name, event, options) do
      :ok ->
        conn

      {:error, reason} ->
        error_fun.(conn, {:error, reason})
    end
  end
end
