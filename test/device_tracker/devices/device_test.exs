defmodule DeviceTracker.Devices.DeviceTest do
  use Assertions.Case, async: true

  alias DeviceTracker.Devices.Device

  describe "add_device/2" do
    # FLAKY TEST - How can we improve it?
    test "allows us to register a device" do
      name = "lightbulb"
      measurement = "power_used"

      assert {:ok, %{measurements: ["power_used"], name: "lightbulb"}} =
               Device.add_device(name, [measurement])

      assert Registry.count(DeviceTracker.Registry) >= 1
    end
  end

  describe "add_measurement/3" do
    test "Allows us to add measurements" do
      name = "lightbulb2"
      measurement = "power_used"
      assert {:ok, _} = Device.add_device(name, [measurement])

      assert {:ok, %{measurement: "power_used", measurements: [1]}} =
               Device.add_measurement(name, measurement, 1)

      assert {:ok, %{measurement: "power_used", measurements: [2, 1]}} =
               Device.add_measurement(name, measurement, 2)
    end
  end

  describe "get_measurements/2" do
    test "gets measurements for a given device" do
      name = "lightbulb3"
      measurement = "power_used"
      assert {:ok, _} = Device.add_device(name, [measurement])
      assert {:ok, []} = Device.get_measurements(name, measurement)
      assert {:ok, _} = Device.add_measurement(name, measurement, 456)
      assert {:ok, [456]} = Device.get_measurements(name, measurement)
    end
  end

  describe "get/1" do
    test "gets all information for the given device" do
      name = "lightbulb4"
      measurement = "power_used"
      assert {:ok, _} = Device.add_device(name, [measurement])
      assert {:ok, _} = Device.add_measurement(name, measurement, 456)
      assert {:ok, %{}} = Device.get(name)
    end

    test "returns an error tuple if the device doesn't exist" do
      assert {:error, :not_found} == Device.get("not_a_device")
    end
  end

  describe "list_all/0" do
    test "lists all information for all devices" do
      devices = [
        {"lightbulb5", ["power_usage"]},
        {"lightbulb6", ["other_usage"]},
        {"lightbulb7", ["third_usage"]}
      ]

      Enum.each(devices, fn {name, measurements} -> Device.add_device(name, measurements) end)

      assert {:ok, all_devices} = Device.list_all()
      Enum.each(devices, fn {name, _} ->
        assert_map_in_list(%{name: name}, all_devices, [:name])
      end)
    end
  end

  describe "update/2" do
    test "updates settings for the given device" do
      name = "lightbulb8"
      measurement = "power_used"
      assert {:ok, _} = Device.add_device(name, [measurement])

      assert {:ok,
              %{
                power_status: :off,
                max_measurements: 10,
                group_name: "Living room"
              }} =
               Device.update(name, %{
                 :power_status => :off,
                 :max_measurements => 10,
                 "group_name" => "Living room"
               })
    end
  end

  describe "delete/1" do
    test "deletes the given device" do
      name = "lightbulb9"
      measurement = "power_used"

      assert {:ok, _} = Device.add_device(name, [measurement])
      assert {:ok, %{}} = Device.get(name)
      assert {:ok, _} = Device.delete(name)
      assert {:error, :not_found} = Device.get(name)
    end
  end
end
