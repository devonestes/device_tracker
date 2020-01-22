defmodule DeviceTracker.MetricsTest do
  use ExUnit.Case, async: true

  alias DeviceTracker.Metrics

  describe "average/1" do
    test "returns the correct average" do
      assert Metrics.average([1, 2, 3, 4]) == 2.5
      assert Metrics.average([0, 0, 0]) == 0
    end
  end
end
