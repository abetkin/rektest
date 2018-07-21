# Metrics

To run the application and to drop into iex shell:

```iex -S mix run```

Each metric is a separate process, supervised by a [DynamicSupervisor](https://hexdocs.pm/elixir/master/DynamicSupervisor.html).
This superviser takes care of registering the new processes by the metrics name as well as monitoring and resterting them on failure.

```
iex(1)> Metrics.Server.new_metric :score
#PID<0.136.0>
iex(2)> Process.whereis :score
#PID<0.136.0>
```

Then you can start reporting values for a metric. Let's test the 2 API functions, `report` and `average`:

```
iex(2)> Metrics.Server.average :score
{:error, "no data yet"}
iex(3)> Metrics.Server.report :score, 1
:ok
iex(4)> Metrics.Server.report :score, 2
:ok
iex(5)> Metrics.Server.report :score, 3
:ok
iex(6)> Metrics.Server.average :score
2.0
```

The state of a metrics process is a map, actually, an elixir struct, [Metric](https://github.com/abetkin/rektest/blob/master/lib/metric.ex#L4).
The values of a metric are accumulated in a list. For simplicity, the length of a metrics sample is a hardcoded constant ([`@len`](https://github.com/abetkin/rektest/blob/master/lib/metric.ex#L2)).
To help with calculating of a moving average a reversed list of values is kept. The sizes of these two lists are varying but are restored to `@len` once in a while.

For `@len = 5`:

```
iex(1)> m = %Metric{}
%Metric{list: [], reversed: nil, sum: nil}
iex(2)> m = m |> Metric.append(1)
%Metric{list: [1], reversed: nil, sum: nil}
iex(3)> m = m |> Metric.append(2) |> Metric.append(3) |> Metric.append(4)
%Metric{list: [4, 3, 2, 1], reversed: nil, sum: nil}
iex(4)> m = m |> Metric.append(5)
%Metric{list: [5, 4, 3, 2, 1], reversed: nil, sum: nil}
iex(5)> m = m |> Metric.append(6)
%Metric{list: [6, 5, 4, 3, 2, 1], reversed: [2, 3, 4, 5], sum: 20}
iex(6)> m = m |> Metric.append(7)
%Metric{list: [7, 6, 5, 4, 3, 2, 1], reversed: [3, 4, 5], sum: 25}
iex(7)> m = m |> Metric.append(8)
%Metric{list: [8, 7, 6, 5, 4, 3, 2, 1], reversed: [4, 5], sum: 30}
iex(8)> m = m |> Metric.append(9)
%Metric{list: [9, 8, 7, 6, 5, 4, 3, 2, 1], reversed: [5], sum: 35}
iex(9)> m = m |> Metric.append(10)
%Metric{list: [10, 9, 8, 7, 6, 5, 4, 3, 2, 1], reversed: [], sum: 40}
iex(10)> m = m |> Metric.append(11)
%Metric{list: '\v\n\t\b\a', reversed: '\a\b\t\n\v', sum: 45}
```

Looks like we've got some problems with formatting here:

```
iex(11)> m.list |> Enum.join(", ")
"11, 10, 9, 8, 7"
iex(12)> m.reversed |> Enum.join(", ")
"7, 8, 9, 10, 11"
```

We see that avery time the sum increases by 5, that is what we expected.

```
iex(13)> m |> Metric.get_average
9.0
```