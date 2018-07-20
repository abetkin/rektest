

m = %Metric{}
m = m
|> Metric.append(1)
|> Metric.append(2)
|> Metric.append(3)
|> Metric.append(4)
|> Metric.append(5)
|> Metric.append(6)
|> Metric.append(7)

m |> IO.inspect
