
defmodule Metrics.Server do
    use GenServer
  
    ## API
  
    def start_link(name) do
      GenServer.start_link(__MODULE__, %Metric{}, name: name)
    end
  
    def get_metric(name) do
      # get or create metric
      case Process.whereis(name) do
        nil ->
          {:ok, pid} = Metrics.Supervisor |> DynamicSupervisor.start_child(%{
            id: name,
            start: {__MODULE__, :start_link, [name]},
          })
          pid
        pid -> pid
      end
    end
  
    def report(name, value) do
      :ok = name |> GenServer.cast({:report, value})
    end
  
    def average(name) do
      name |> GenServer.call({:average})
    end
  
    # Server
  
    def handle_cast({:report, value}, metric) do
      {:noreply, metric |> Metric.append(value)}
    end
  
    def handle_call({:average}, _from, metric) do
      {:reply, metric |> Metric.get_average, metric}
    end
  end
  
