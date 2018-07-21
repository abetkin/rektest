
defmodule Metrics.Server do
    use GenServer
  
    ## API
  
    def start_link(name) do
      # function is a part of the child spec, to be used by the supervisor
      GenServer.start_link(__MODULE__, %Metric{}, name: name)
    end
  
    def new_metric(name) do
      {:ok, pid} = Metrics.Supervisor |> DynamicSupervisor.start_child(%{
        id: name,
        start: {__MODULE__, :start_link, [name]},
      })
      pid
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
  
