defmodule Kalevala.Help do
  @moduledoc """
  Help Topics

  A cache for help topics that the user can look up.
  """

  use Supervisor

  alias Kalevala.Help.Cache
  alias Kalevala.Help.KeywordCache

  @doc """
  Put a topic in the cache
  """
  def put(help_topic) do
    Cache.put(help_topic.key, help_topic)
    KeywordCache.put(help_topic)
  end

  @doc """
  Get a help topic from the cache
  """
  def get(topic), do: Cache.get(topic)

  @doc false
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))
  end

  @doc false
  def init(_) do
    children = [
      {Cache, [name: Cache, id: Cache]},
      {KeywordCache, [name: KeywordCache, id: KeywordCache]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Kalevala.Help.Cache do
  @moduledoc false

  use Kalevala.Cache
end

defmodule Kalevala.Help.KeywordCache do
  @moduledoc """
  A small cache to be a lookup from keyword -> help topic key
  """

  use Kalevala.Cache

  @doc false
  def put(help_topic) do
    Enum.map(help_topic.keywords, fn keyword ->
      put(keyword, help_topic.key)
    end)
  end
end

defmodule Kalevala.Help.HelpTopic do
  @moduledoc """
  Struct for help topics
  """

  defstruct [:content, :key, :tagline, :title, keywords: [], see_also: []]
end
