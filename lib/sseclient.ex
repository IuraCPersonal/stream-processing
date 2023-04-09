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
    HTTPoison.get!(url, [], recv_timeout: :infinity, stream_to: self())
    {:ok, url}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncChunk{chunk: ""}, url) do
    HTTPoison.get!(url, [], recv_timeout: :infinity, stream_to: self())
    {:noreply, url}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncChunk{chunk: "event: \"message\"\n\ndata: {\"message\": panic}\n\n"}, url) do
    # TODO: Restart Actor.
    {:noreply, url}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncChunk{chunk: data}, url) do
    [_, json] = Regex.run(~r/data: ({.+})\n\n$/, data)
    {:ok, result} = json |> Poison.decode()

    StreamSupervisor.get_worker(LoadBalancer)
    |> send(result)

    {:noreply, url}
  end

  @impl true
  def handle_info(_, url) do
    {:noreply, url}
  end
end
