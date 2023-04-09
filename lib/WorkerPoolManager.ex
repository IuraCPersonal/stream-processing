defmodule WorkerPoolManager do
  use Supervisor
  require Logger

  @syntax_colors [
    number: :yellow,
    atom: :cyan,
    string: :green,
    boolean: :magenta,
    nil: :magenta
  ]

  @format [
    pretty: true,
    structs: true,
    syntax_colors: @syntax_colors
  ]

  def start_link({type, count}) do
    # 🦄 Bookmark: Logger.
    Logger.notice("[SSE] Worker Pool Manager (#{type}) starting...", @format)

    children = handle_children(type, count)
    name = handle_name(type)

    Supervisor.start_link(
      __MODULE__,
      children,
      name: name
    )
  end

  @impl true
  def init(children) do
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp handle_children(type, count) do
    {name, module} =
      case type do
        :printer -> {"printer", Printer}
        :sentiment_scorer -> {"sentiment_scorer", SentimentScoreActor}
        :engagement_ratio_scorer -> {"engagement_ratio_scorer", EngagementRatioActor}
      end

    1..count
    |> Enum.map(fn n ->
      %{
        id: :"#{name}#{n}",
        start: {module, :start_link, [:"#{name}#{n}"]}
      }
    end)
  end

  # Get Type of Worker Pool.
  defp handle_name(type) do
    case type do
      :printer -> PrintersWorkerPool
      :sentiment_scorer -> SentimentsWorkerPool
      :engagement_ratio_scorer -> EngagementsWorkerPool
    end
  end

  def get_worker_pool(type, count) do
    id = handle_name(type)

    %{
      id: id,
      start: {WorkerPoolManager, :start_link, [{type, count}]}
    }
  end
end
