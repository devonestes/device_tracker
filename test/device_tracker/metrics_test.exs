defmodule DeviceTracker.MetricsTest do
  use ExUnit.Case, async: true

  alias DeviceTracker.Metrics

  describe "average/1" do
    test "returns the correct average" do
      assert Metrics.average([1, 2, 3, 4]) == 2.5
      assert Metrics.average([0, 0, 0]) == 0
      assert Metrics.average([]) == nil
    end
  end

  describe "median/1" do
    test "returns the element in the middle of the list after being sorted" do
      assert Metrics.median([1, 2, 3]) == 2
      assert Metrics.median([2, 3, 1]) == 2
      assert Metrics.median([]) == nil
    end
  end

  describe "mean/1" do
    test "returns the element that appears most often" do
      assert Metrics.mean([1, 2, 2, 3]) == 2
      assert Metrics.mean([3, 1, 2, 3]) == 3
      assert Metrics.mean([]) == nil
    end
  end
end
