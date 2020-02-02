defmodule DeviceTrackerWeb.Features.DevicesTest do
  use DeviceTrackerWeb.FeatureCase, async: true

  alias DeviceTracker.Devices.Device

  describe "GET /devices" do
    test "lists all devices", %{session: session} do
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

    # test "lists devices in alphabetical order", %{session: session} do
    # end

    # test "groups devices if they're linked together in a group", %{session: session} do
    # end

    # test "groups are sorted from smallest to largest", %{session: session} do
    # end
  end

  describe "GET /devices/:id" do
    test "shows information for a single device", %{session: session} do
      {:ok, device} = Device.add_device("device9", ["brightness"])

      session
      |> visit(device_path(:show, device.name))
      |> assert_has(css(".device", text: "device9"))
    end

    # test "should always show all measurement types", %{session: session} do
    # end

    # test "should not show data for a device if it is marked as off", %{session: session} do
    # end
  end
end
