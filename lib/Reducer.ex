defmodule Reducer do
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
    Logger.notice("[SSE] Reducer starting...", @format)

    GenServer.start_link(
      __MODULE__,
      {id},
      name: id
    )
  end

  @impl true
  def init(_init_args) do
    {:ok, {%{}, %{}}}
  end

  @impl true
  def handle_info({:formatted_text, ref, name, text}, {tweet_map, user_map}) do
    value = Map.get(tweet_map, ref, %{})
    value = Map.put(value, :formatted_text, {name, text})

    tweet_map =
      if check_and_print(value, user_map),
        do: Map.delete(tweet_map, ref),
        else: Map.put(tweet_map, ref, value)

    {:noreply, {tweet_map, user_map}}
  end

  @impl true
  def handle_info({:sentiment_score, ref, name, score}, {tweet_map, user_map}) do
    value = Map.get(tweet_map, ref, %{})
    value = Map.put(value, :sentiment_score, {name, score})

    tweet_map =
      if check_and_print(value, user_map),
        do: Map.delete(tweet_map, ref),
        else: Map.put(tweet_map, ref, value)

    {:noreply, {tweet_map, user_map}}
  end

  @impl true
  def handle_info({:engagement_ratio_score, ref, name, score, user_id}, {tweet_map, user_map}) do
    value = Map.get(tweet_map, ref, %{})
    value = Map.put(value, :engagement_ratio_score, {name, score, user_id})

    user_map = Map.update(user_map, user_id, score, &(&1 + score))

    tweet_map =
      if check_and_print(value, user_map),
        do: Map.delete(tweet_map, ref),
        else: Map.put(tweet_map, ref, value)

    {:noreply, {tweet_map, user_map}}
  end

  defp check_and_print(map, user_map) do
    if map |> Map.keys() |> length() == 3 do
      {printer, text} = map.formatted_text
      {sentiment_scorer, sentiment_score} = map.sentiment_score
      {engagement_ratio_scorer, engagement_ratio_score, user_id} = map.engagement_ratio_score

      Logger.info("[#{printer}] - #{text}")
      Logger.warning("[#{sentiment_scorer}] - #{sentiment_score}")
      Logger.critical("[#{engagement_ratio_scorer}] - #{engagement_ratio_score}")
      Logger.debug("[U#{user_id}] - Engagement Ratio Score for user: #{Map.get(user_map, user_id)}\n")

      true
    else
      false
    end
  end
end
