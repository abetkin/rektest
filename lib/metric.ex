defmodule Metric do
  use ShortDef

  @len 5

  defstruct [
    list: [],
    reversed: nil,
    sum: nil,
  ]

  def append(%Metric{list, reversed: nil} = m, value) when length(list) < @len do
    # Initial population of the list
    %Metric{m |
      list: [value | list],
    }
  end

  def append(%Metric{list, reversed: nil}, value) when length(list) == @len do
    # length(list) has reached @len (as a result of its initial population)
    m = %Metric{
      list: list,
      reversed: Enum.reverse(list),
      sum: Enum.sum(list),
    }
    append(m, value)
  end

  def append(%Metric{list, sum, reversed: []}, value) do
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

  def append(%Metric{list, reversed, sum}, value) when length(reversed) != 0 do
    # general case
    [last | new_reversed] = reversed
    %Metric{
      list: [value | list],
      reversed: new_reversed,
      sum: sum + value - last,
    }
  end

  def get_average(%Metric{list: []}) do
    {:error, "no data yet"}
  end

  def get_average(%Metric{list, sum: nil}) do
    Enum.sum(list) / length(list)
  end

  def get_average(%Metric{sum}) do
    sum / @len
  end

end

