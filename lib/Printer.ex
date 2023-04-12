defmodule Printer do
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
    Logger.notice("[SSE] Printer Actor starting...", @format)

    GenServer.start_link(
      __MODULE__,
      {id},
      name: id
    )
  end

  @impl true
  def init({id}) do
    {:ok, data} = File.read("data/bad_words.json")
    {:ok, dict} = Poison.decode(data)

    bad_words =
      dict["RECORDS"]
      |> Enum.map(fn map ->
        Map.get(map, "word")
      end)

    {:ok, %{name: id, load: 0, bad_words: bad_words}}
  end

  @impl true
  def handle_info({data, ref}, state) do
    processed_message =
      data["message"]["tweet"]["text"]
      |> String.replace("\n", " ")
      |> String.slice(0, 45)
      |> String.split(" ", trim: True)

    filtered_message =
      processed_message
      |> Enum.map(fn word ->
        case Enum.member?(state.bad_words, word) do
          false ->
            word

          true ->
            String.duplicate("*", String.length(word))
        end
      end)

    StreamSupervisor.get_worker(Reducer)
    |> send({:formatted_text, ref, state.name, Enum.join(filtered_message, " ")})

    {:noreply, state}
  end
end
