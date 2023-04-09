defmodule LoadBalancer do
  use GenServer
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

  def start_link(:ok) do
    # 🦄 Bookmark: Logger.
    Logger.notice("[SSE] Load Balancer Actor starting...", @format)

    GenServer.start_link(
      __MODULE__,
      name: __MODULE__
    )
  end

  @impl true
  def init(_init_args) do
    {:ok, nil}
  end

  @impl true
  def handle_info(":panik", state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(data, state) do
    hash_distribution_key = data["message"]["tweet"]["text"]
    last_byte = :crypto.hash(:sha256, hash_distribution_key) |> :binary.last()

    [printers_count, sentiments_workers_count, engagement_ratio_workerks_count] =
      [PrintersWorkerPool, SentimentsWorkerPool, EngagementsWorkerPool]
      |> Enum.map(&Supervisor.count_children(&1).specs)

    [printer, sentiment_scorer, engagement_ratio_scorer] =
      [
        {"printer", printers_count},
        {"sentiment_scorer", sentiments_workers_count},
        {"engagement_ratio_scorer", engagement_ratio_workerks_count}
      ]
      |> Enum.map(fn {name, i} ->
        :"#{name}#{(last_byte |> rem(i)) + 1}"
      end)

    # Returns an almost unique reference.
    # https://hexdocs.pm/elixir/1.12/Kernel.html#make_ref/0
    ref = make_ref()

    [printer, sentiment_scorer, engagement_ratio_scorer] 
    |> Enum.map(&send(&1, {data, ref}))

    {:noreply, state}
  end
end
