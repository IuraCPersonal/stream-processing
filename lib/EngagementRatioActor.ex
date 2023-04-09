defmodule EngagementRatioActor do
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

  def start_link(id) do
    # 🦄 Bookmark: Logger.
    Logger.notice("[SSE] Engagement Ratio Actor starting...", @format)

    GenServer.start_link(
      __MODULE__,
      {id},
      name: id
    )
  end

  @impl true
  def init({name}) do
    {:ok, %{id: name}}
  end

  @impl true
  def handle_info({data, ref}, state) do
    user_id = data["message"]["tweet"]["user"]["id"]

    engagement_ratio_score = engagement_ratio_handler(data)

    StreamSupervisor.get_worker(Reducer)
    |> send({:engagement_ratio_score, ref, state.id, engagement_ratio_score, user_id})

    {:noreply, state}
  end

  defp engagement_ratio_handler(data) do
    favorite_count = data["message"]["tweet"]["retweeted_status"]["favorite_count"] || 0
    retweet_count = data["message"]["tweet"]["retweeted_status"]["retweet_count"] || 0
    followers_count = data["message"]["tweet"]["user"]["followers_count"]

    engagement_ratio_score = try do
      (favorite_count + retweet_count) / followers_count
    rescue
      ArithmeticError -> 0
    end

    engagement_ratio_score
  end
end
