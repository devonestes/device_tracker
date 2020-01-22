defmodule DeviceTracker.Metrics do
  def average(measurements) do
    Enum.sum(measurements) / length(measurements)
  end
end
