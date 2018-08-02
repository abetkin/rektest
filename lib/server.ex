
defmodule State do
  defstruct [
    :start,
    list: [],
    metric: %Metric{},
  ]
end

defmodule Metrics.Server do
    use GenServer
    use ShortDef

    ## API

    @beat_interval 3_000

    def start_link(name) do
      # function is a part of the child spec, to be used by the supervisor
      Task.async(fn -> schedule_pulse(name) end)
      GenServer.start_link(__MODULE__, %State{}, name: name)
    end

    defp schedule_pulse(name) do
      receive do
      after @beat_interval ->
        name |> GenServer.cast(:pulse)
        schedule_pulse(name)
      end
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

    def init(%State{} = s) do
      {:ok, s}
    end

    def handle_cast({:report, value}, %State{list, metric} = s) do
      new_state = %State{s | list: [value | list]}
      # TODO handle time
      {:noreply, new_state}
    end

    def handle_cast(:pulse, %State{list, metric} = state) do
      avg = case list do
        [] -> 0
        _ -> Enum.sum(list) / length(list)
      end
      |> IO.inspect(label: :new)
      metric = metric |> Metric.append(avg)
      new_state = %State{state | metric: metric, list: []}
      {:noreply, new_state}
    end

    def handle_call({:average}, _from, %State{metric} = s) do
      {:reply, metric |> Metric.get_average, s}
    end
  end

