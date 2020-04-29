defmodule Kalevala.Output.Context do
  @moduledoc """
  Context struct for an output callback module
  """

  defstruct data: [], meta: %{}, processed: []
end

defmodule Kalevala.Output do
  @moduledoc """
  An output post processor for text from Kalevala

  Allow the game to modify text leaving Kalevala, such as to insert
  ANSI codes for color.
  """

  alias Kalevala.Output.Context

  @callback init() :: Context.t()

  @callback parse(String.t(), Context.t()) :: Context.t()

  @callback post_parse(Context.t()) :: Context.t()

  @callback process(any(), Context.t()) :: Context.t()

  def process(text_data, callback_module) do
    context = callback_module.init()

    context =
      Enum.reduce(text_data, context, fn datum, context ->
        parse(datum, callback_module, context)
      end)

    context = callback_module.post_parse(context)

    context =
      Enum.reduce(context.data, callback_module.init(), fn datum, context ->
        callback_module.process(datum, context)
      end)

    context.data
  end

  def parse(data, callback_module, context) when is_list(data) do
    Enum.reduce(data, context, &parse(&1, callback_module, &2))
  end

  def parse(data, callback_module, context) do
    callback_module.parse(data, context)
  end
end

defmodule Kalevala.Output.Tags do
  @moduledoc """
  Output processor that parses tags
  """

  @behaviour Kalevala.Output

  alias Kalevala.Output.Context

  @impl true
  def init() do
    %Context{
      data: [],
      processed: [],
      meta: %{
        current_tag: <<>>,
        current_string: <<>>,
        tag_stack: []
      }
    }
  end

  def foreground_color("black"), do: IO.ANSI.black()
  def foreground_color("red"), do: IO.ANSI.red()
  def foreground_color("green"), do: IO.ANSI.green()
  def foreground_color("yellow"), do: IO.ANSI.yellow()
  def foreground_color("blue"), do: IO.ANSI.blue()
  def foreground_color("magenta"), do: IO.ANSI.magenta()
  def foreground_color("cyan"), do: IO.ANSI.cyan()
  def foreground_color("white"), do: IO.ANSI.white()

  def process_tag("color", attributes) do
    attributes = Enum.into(attributes, %{})

    foreground = Map.get(attributes, "foreground")

    [foreground_color(foreground)]
  end

  def process_close_tag([]), do: [IO.ANSI.reset()]

  def process_close_tag([{:open, tag_name, attributes} | _stack]) do
    process_tag(tag_name, attributes)
  end

  @impl true
  def process({:open, tag_name, attributes}, context) do
    tag_stack = [{:open, tag_name, attributes} | context.meta.tag_stack]
    meta = Map.put(context.meta, :tag_stack, tag_stack)

    context
    |> Map.put(:data, context.data ++ process_tag(tag_name, attributes))
    |> Map.put(:meta, meta)
  end

  def process({:close, tag_name}, context) do
    [{:open, ^tag_name, _attributes} | tag_stack] = context.meta.tag_stack
    meta = Map.put(context.meta, :tag_stack, tag_stack)

    context
    |> Map.put(:data, context.data ++ process_close_tag(tag_stack))
    |> Map.put(:meta, meta)
  end

  def process(datum, context) do
    Map.put(context, :data, context.data ++ [datum])
  end

  @impl true
  def post_parse(context) do
    context
    |> Map.put(:data, context.data ++ [context.meta.current_string])
    |> Map.put(:meta, %{})
  end

  @impl true
  def parse(string, context) do
    {current_tag, current_string, processed} =
      parse_string(string, context.meta.current_tag, context.meta.current_string, [])

    meta =
      context.meta
      |> Map.put(:current_tag, current_tag)
      |> Map.put(:current_string, current_string)

    context
    |> Map.put(:data, context.data ++ processed)
    |> Map.put(:meta, meta)
  end

  def parse_string(<<>>, current_tag, current_string, processed),
    do: {current_tag, current_string, processed}

  def parse_string(<<"\\{"::utf8, string::binary>>, <<>>, current_string, processed) do
    parse_string(string, <<>>, current_string <> "{", processed)
  end

  def parse_string(<<"\\{"::utf8, string::binary>>, current_tag, current_string, processed) do
    parse_string(string, current_tag <> "{", current_string, processed)
  end

  def parse_string(<<"\\}"::utf8, string::binary>>, <<>>, current_string, processed) do
    parse_string(string, <<>>, current_string <> "}", processed)
  end

  def parse_string(<<"\\}"::utf8, string::binary>>, current_tag, current_string, processed) do
    parse_string(string, current_tag <> "}", current_string, processed)
  end

  def parse_string(<<"/"::utf8, string::binary>>, <<>>, current_string, processed) do
    parse_string(string, <<>>, current_string <> "/", processed)
  end

  def parse_string(<<"/"::utf8, string::binary>>, current_tag, current_string, processed) do
    parse_string(string, current_tag <> "/", current_string, processed)
  end

  def parse_string(<<"{"::utf8, string::binary>>, _current_tag, current_string, processed) do
    parse_string(string, "{", <<>>, processed ++ [current_string])
  end

  def parse_string(<<"}"::utf8, string::binary>>, current_tag, current_string, processed) do
    tag = parse_tag(current_tag <> "}")

    parse_string(string, <<>>, current_string, processed ++ [tag])
  end

  def parse_string(<<character::utf8, string::binary>>, <<>>, current_string, processed) do
    parse_string(string, <<>>, current_string <> <<character>>, processed)
  end

  def parse_string(<<character::utf8, string::binary>>, current_tag, current_string, processed) do
    parse_string(string, current_tag <> <<character>>, current_string, processed)
  end

  def parse_tag("{/" <> name) do
    {:close, String.replace(name, "}", "")}
  end

  def parse_tag(tag) do
    [tag_name | attributes] = Enum.reverse(parse_tag_attributes(tag))

    tag_name =
      tag_name
      |> String.replace(~r/[{}]/, "")
      |> String.trim()

    {:open, tag_name, attributes}
  end

  def parse_tag_attributes(tag) do
    case Regex.run(~r/(?<name>[\w-]+)="(?<value>[^"]+)"/, tag) do
      [string, name, value] ->
        [{name, value} | parse_tag_attributes(String.replace(tag, string, ""))]

      _ ->
        [tag]
    end
  end
end
