defmodule DeviceTracker.Metrics do
  def average([]), do: nil
  def average(list), do: Enum.sum(list) / length(list)

  def median(list) do
    list
    |> Enum.sort()
    |> Enum.at(floor(length(list) / 2))
  end

  def mean([]), do: nil
  def mean(list) do
    list
    |> Enum.frequencies()
    |> Enum.max_by(fn {_, v} -> v end)
    |> elem(0)
  end
end
