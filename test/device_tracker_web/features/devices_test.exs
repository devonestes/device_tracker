defmodule DeviceTrackerWeb.Features.DevicesTest do
  use DeviceTrackerWeb.FeatureCase

  alias DeviceTracker.Devices.Device

  setup do
    Device.clear()

    devices = [
      {"device5", "brightness"},
      {"device6", "power_usage"},
      {"device7", "other_usage"},
      {"device8", "third_usage"},
      {"device9", "volume"}
    ]

    Enum.each(devices, fn {name, measurement} ->
      Device.add_device(name, [measurement])
      Device.add_measurement(name, measurement, 291)
    end)
  end

  describe "GET /devices" do
    test "lists devices in alphabetical order", %{session: session} do
      session
      |> visit(device_path(:index))
      |> assert_has(css(".device:nth-of-type(1)", text: "device5"))
      |> assert_has(css(".device:nth-of-type(2)", text: "device6"))
      |> assert_has(css(".device:nth-of-type(3)", text: "device7"))
      |> assert_has(css(".device:nth-of-type(4)", text: "device8"))
      |> assert_has(css(".device:nth-of-type(5)", text: "device9"))
    end

    test "groups devices, with groups sorted from largest to smallest", %{session: session} do
      devices = [
        {"device5", "kitchen"},
        {"device6", "living_room"},
        {"device7", "living_room"},
        {"device8", "kitchen"},
        {"device9", "living_room"}
      ]

      Enum.each(devices, fn {name, group_name} ->
        Device.update(name, %{"group_name" => group_name})
      end)

      session
      |> visit(device_path(:index))
      |> assert_has(css(".device:nth-of-type(1)", text: "device6"))
      |> assert_has(css(".device:nth-of-type(2)", text: "device7"))
      |> assert_has(css(".device:nth-of-type(3)", text: "device9"))
      |> assert_has(css(".device:nth-of-type(4)", text: "device5"))
      |> assert_has(css(".device:nth-of-type(5)", text: "device8"))
    end
  end

  describe "GET /devices/:id" do
    test "shows information for a single device", %{session: session} do
      {:ok, device} = Device.update("device6", %{
        measurements: %{power_usage: %{measurements: [291]}, wattage: %{measurements: [21]}}
      })

      session
      |> visit(device_path(:show, device.name))
      |> assert_has(css(".device", text: device.name))
      |> assert_has(Query.text("wattage"))
      |> assert_has(Query.text("power_usage"))
    end

    test "should not show data for a device if it is marked as off", %{session: session} do
      {:ok, device} = Device.update("device6", %{power_status: :off})

      session
      |> visit(device_path(:show, device.name))
      |> refute_has(css(".measurements"))
    end
  end
end
