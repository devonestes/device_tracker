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
end
