defmodule Throughput do end
defmodule Latency do end


defmodule MetricsApp.Application do
  use Application

  @metrics_list [
    Throughput, Latency,
  ]

  def start(_type, _args) do
    # List all child processes to be supervised
    children = for M <- @metrics_list do
      %{
        id: M,
        start: {MetricsApp, :start_link, [M, [:hello]]}
      }
    end
    opts = [strategy: :one_for_one, name: MetricsApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
