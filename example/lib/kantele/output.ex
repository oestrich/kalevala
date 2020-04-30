defmodule Kantele.Output.SemanticColors do
  @moduledoc false

  @behaviour Kalevala.Output

  alias Kalevala.Output.Context

  @impl true
  def init(opts) do
    %Context{
      data: [],
      opts: opts
    }
  end

  @impl true
  def post_parse(context), do: context

  @impl true
  def parse(tag, context) do
    tag = transform_tag(tag)
    Map.put(context, :data, context.data ++ [tag])
  end

  def transform_tag({:open, "character", attributes}) do
    {:open, "color", Map.merge(attributes, %{"foreground" => "white"})}
  end

  def transform_tag({:close, "character"}) do
    {:close, "color"}
  end

  def transform_tag(tag), do: tag
end
