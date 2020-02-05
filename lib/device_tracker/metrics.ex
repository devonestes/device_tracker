defmodule DeviceTracker.Metrics do
  def average([]), do: 0
  def average(measurements), do: Enum.sum(measurements) / length(measurements)
end
