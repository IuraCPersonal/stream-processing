defmodule StreamSupervisor do
  use Supervisor
  require Logger

  def start_link(args) do
    # 🦄 Bookmark: Logger.
    Logger.notice("[SSE] Stream Supervisor starting...")

    Supervisor.start_link(
      __MODULE__,
      args,
      name: __MODULE__
    )
  end

  def init(_init_args) do
    children = [
      # Actors to read SSE Streams:
      %{
        id: :sseclient_1,
        start: {SseClient, :start_link, [:sseclient_1, "http://localhost:4000/tweets/1"]}
      },
      %{
        id: :sseclient_2,
        start: {SseClient, :start_link, [:sseclient_2, "http://localhost:4000/tweets/2"]}
      }
    ]

    Supervisor.init(
      children,
      strategy: :one_for_one,
      # TODO: Change to Infinity.
      max_restarts: 1000
    )
  end

  # Get Worker's pid by ID.
  def get_worker(id) do
    {^id, pid, _type, _modules} =
      __MODULE__
      |> Supervisor.which_children()
      |> Enum.find(fn {worker_id, _pid, _type, _modules} ->
        worker_id == id
      end)

    pid
  end
end
