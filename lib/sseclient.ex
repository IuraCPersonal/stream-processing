defmodule SseClient do
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

  def start_link(id, url) do
    # 🦄 Bookmark: Logger.
    Logger.warning("[SSE] Stream Reader starting...", @format)

    GenServer.start_link(
      __MODULE__,
      url,
      name: id
    )
  end

  @impl true
  def init(url) do
    Logger.alert("[SSE] Trying to connect to #{url}", @format)

    # 👇 Get the Stream Data
    HTTPoison.get!(
      url,
      [],
      recv_timeout: :infinity,
      stream_to: self()
    )

    {:ok, nil}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncChunk{chunk: "event: \"message\"\n\ndata: {\"message\": panic}\n\n"}, _state) do
    Logger.warning("[SSE] Panik Chunk Received", @format)

    {:noreply, nil}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, _state) do
    case Regex.run(~r/data: ({.+})\n\n$/, chunk) do
      # Good Response.
      [_, tweet] ->
        with {:ok, result} <- Poison.decode(tweet) do
          Logger.info("SUCCESS")
        end

      # Bad Response.
      nil -> Logger.error("[SSE] Don't know how to parse received chunk")
    end

    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncStatus{} = status, _state) do
    Logger.info("[SSE] Connection Status - #{inspect(status)}")

    {:noreply, nil}
  end

  def handle_info(_, url) do
    {:noreply, url}
  end
end
