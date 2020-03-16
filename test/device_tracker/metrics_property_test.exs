defmodule DeviceTracker.MetricsPropertyTest do
  use ExUnit.Case, async: true
  use PropCheck

  describe "average/1" do
    property "never returns an error" do
      forall nums <- non_empty(list(number())) do
        {min, max} = Enum.min_max(nums)
        avg = DeviceTracker.Metrics.average(nums)
        assert min <= avg
        assert max >= avg
      end
    end
  end

  describe "median/1" do
    property "never returns an error" do
      forall nums <- non_empty(list(number())) do
        {min, max} = Enum.min_max(nums)
        median = DeviceTracker.Metrics.median(nums)
        assert min <= median
        assert max >= median
      end
    end
  end

  describe "mean/1" do
    property "never returns an error" do
      forall nums <- non_empty(list(number())) do
        mean =
          nums
          |> Enum.frequencies()
          |> Enum.max_by(&elem(&1, 1))
          |> elem(0)

        assert mean == DeviceTracker.Metrics.mean(nums)
      end
    end
  end
end
