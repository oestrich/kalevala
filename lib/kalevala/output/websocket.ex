defmodule Kalevala.Output.Websocket.Tag do
  @moduledoc false

  @derive Jason.Encoder
  defstruct [:name, attributes: %{}, children: []]

  def append(tag, child) do
    %{tag | children: tag.children ++ [child]}
  end
end

defmodule Kalevala.Output.Websocket do
  @moduledoc """
  Processes tags for the websocket output

  Finds matching opening and closing tags and groups children together
  """

  use Kalevala.Output

  alias Kalevala.Output.Websocket.Tag

  @impl true
  def init(opts) do
    %Context{
      data: [],
      opts: opts,
      meta: %{
        current_tag: :empty,
        tag_stack: []
      }
    }
  end

  @impl true
  def parse({:open, tag_name, attributes}, context) do
    parse_open(context, tag_name, attributes)
  end

  def parse({:close, tag_name}, context) do
    parse_close(context, tag_name)
  end

  def parse(datum, context) do
    case context.meta.current_tag == :empty do
      true ->
        Map.put(context, :data, context.data ++ [datum])

      false ->
        current_tag = Tag.append(context.meta.current_tag, datum)
        meta = Map.put(context.meta, :current_tag, current_tag)
        Map.put(context, :meta, meta)
    end
  end

  defp parse_open(context, tag, attributes) do
    tag_stack = [context.meta.current_tag | context.meta.tag_stack]

    meta =
      context.meta
      |> Map.put(:current_tag, %Tag{name: tag, attributes: attributes})
      |> Map.put(:tag_stack, tag_stack)

    Map.put(context, :meta, meta)
  end

  defp parse_close(context, tag_name) do
    [new_current | tag_stack] = context.meta.tag_stack

    current_tag = %{name: ^tag_name} = context.meta.current_tag
    current_tag = %{current_tag | children: current_tag.children}

    case new_current do
      :empty ->
        meta =
          context.meta
          |> Map.put(:current_tag, :empty)
          |> Map.put(:tag_stack, tag_stack)

        context
        |> Map.put(:data, context.data ++ [current_tag])
        |> Map.put(:meta, meta)

      new_current ->
        meta =
          context.meta
          |> Map.put(:current_tag, Tag.append(new_current, current_tag))
          |> Map.put(:tag_stack, tag_stack)

        Map.put(context, :meta, meta)
    end
  end

  @impl true
  def post_parse(context), do: context
end
