defmodule DeviceTrackerWeb.Features.DevicesTest do
  use DeviceTrackerWeb.FeatureCase, async: true

  alias DeviceTracker.Devices.Device

  describe "GET /devices" do
    test "lists all devices", %{session: session} do
      # Shows them in alphabetical
      # Groups devices if they're linked together
      # Groups with the fewest devices show up first in order
      devices = [
        {"device6", ["power_usage"]},
        {"device7", ["other_usage"]},
        {"device8", ["third_usage"]}
      ]

      Enum.each(devices, fn {name, measurements} -> Device.add_device(name, measurements) end)

      session
      |> visit(device_path(:index))
      |> assert_has(css(".device", text: "device6"))
      |> assert_has(css(".device", text: "device7"))
      |> assert_has(css(".device", text: "device8"))
    end
  end

  describe "GET /devices/:id" do
    @tag :skip
    test "shows information for a single device", %{session: _session} do
      # Shows only 3 measurement types even if there is a fourth added
      # Shows data for a device that is off even though it shouldn't
    end
  end
end
