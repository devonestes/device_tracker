defmodule DeviceTracker.Devices.DeviceTest do
  use ExUnit.Case, async: true

  alias DeviceTracker.Devices.Device

  describe "add_device/2" do
    test "allows us to register a device" do
      name = "lightbulb"
      measurement = "power_used"
      assert Device.add_device(name, [measurement]) == name
      assert Registry.count(DeviceTracker.Registry) == 1

      assert DynamicSupervisor.count_children(DeviceTracker.DynamicSupervisor) == %{
               active: 1,
               specs: 1,
               supervisors: 0,
               workers: 1
             }
    end
  end

  describe "add_measurement/3" do
    test "Allows us to add measurements" do
      name = "lightbulb2"
      measurement = "power_used"
      Device.add_device(name, [measurement])

      assert Device.get_measurements(name, measurement) == []
      assert Device.add_measurement(name, measurement, 1) == :ok
      assert Device.add_measurement(name, measurement, 2) == :ok
      assert Device.get_measurements(name, measurement) == [2, 1]
    end
  end
end
