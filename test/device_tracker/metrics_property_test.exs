defmodule DeviceTracker.MetricsPropertyTest do
  use ExUnit.Case, async: true
  use PropCheck

  describe "average/1" do
    property "returns something between the min and max of the input set" do
      forall nums <- non_empty(list(number())) do
        {min, max} = Enum.min_max(nums)
        avg = DeviceTracker.Metrics.average(nums)
        assert min <= avg
        assert max >= avg
      end
    end
  end

  describe "median/1" do
  end

  describe "mean/1" do
  end
end
