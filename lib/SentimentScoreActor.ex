defmodule SentimentScoreActor do
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
    Logger.notice("[SSE] Sentiment Score Actor starting...", @format)

    GenServer.start_link(
      __MODULE__,
      {id},
      name: id
    )
  end

  @impl true
  def init({name}) do
    word_score_map = handle_word_score()

    {:ok, %{id: name, word_score_map: word_score_map}}
  end

  @impl true
  def handle_info({data, ref}, state) do
    sentiment_score = handle_sentiment_score(data, state.word_score_map)

    send(Reducer, {:sentiment_score, ref, state.id, sentiment_score})

    {:noreply, state}
  end

  defp handle_word_score() do
    emotional_endpoint = "http://localhost:4000/emotion_values"
    %{body: response} = HTTPoison.get!(emotional_endpoint)

    word_score_map =
      response
      |> String.split("\r\n")
      |> Enum.map(&String.split(&1, "\t"))
      |> Enum.reduce(%{}, fn [key, value], map ->
        {value, ""} = Integer.parse(value)
        Map.put(map, key, value)
      end)

    word_score_map
  end

  defp handle_sentiment_score(message, word_score_map) do
    text =
      message["message"]["tweet"]["text"]
      |> String.replace("\n", " ")

    words =
      text |> String.split(" ", trim: True)

    sum =
      words |> Enum.reduce(0, fn word, acc ->
        acc + Map.get(word_score_map, word, 0)
      end)

    score = sum / length(words)
    score
  end
end
