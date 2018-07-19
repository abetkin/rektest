defmodule Metric do
  @moduledoc """

  """

  @len 3 # from config / process

  defstruct [
    list: [],
    reversed: nil,
    sum: nil,
  ]

  def append(%Metric{list: list, reversed: nil} = m, value) when length(list) < @len do
    %Metric{m |
      list: [value | list],
    }
  end

  def append(%Metric{list: list, reversed: nil} = m, value) when length(list) == @len do
    m = %Metric{
      list: list,
      reversed: Enum.reverse(list),
      sum: Enum.sum(list),
    }
    append(m, value)
  end

  def append(%Metric{list: list, reversed: [], sum: sum}, value) do
    # reversed has been shrunk to []
    {new_list, [last]} = list
    |> Stream.take(@len)
    |> Enum.split(@len - 1)
    new_list = [value | new_list]
    %Metric{
      list: new_list,
      reversed: Enum.reverse(new_list),
      sum: sum + value - last,
    }
  end

  def append(%Metric{list: list, reversed: reversed, sum: sum} = m, value) when length(reversed) != 0 do
    # general case
    [last | new_reversed] = reversed
    %Metric{
      list: [value | list],
      reversed: new_reversed,
      sum: sum + value - last,
    }
  end

end


defmodule MetricApp do
  use GenServer

  ## Client API


  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %Metric{}}
  end

  def handle_cast({:report, name, value}, _from, _) do
    {:noreply}
  end

  def handle_call({:average, name}, names) do
    if Map.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      {:noreply, Map.put(names, name, bucket)}
    end
  end
end
