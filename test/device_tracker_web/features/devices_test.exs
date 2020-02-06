defmodule DeviceTrackerWeb.Features.DevicesTest do
  use DeviceTrackerWeb.FeatureCase

  alias DeviceTracker.Devices.Device

  setup_all do
    Device.clear()

    devices = [
      {"device6", "power_usage"},
      {"device7", "other_usage"},
      {"device8", "third_usage"}
    ]

    Enum.each(devices, fn {name, measurement} ->
      Device.add_device(name, [measurement])
      Device.add_measurement(name, measurement, 291)
    end)
  end

  describe "GET /devices" do
    test "lists all devices", %{session: session} do
      session
      |> visit(device_path(:index))
      |> assert_has(css(".device", text: "device6"))
      |> assert_has(css(".device", text: "device7"))
      |> assert_has(css(".device", text: "device8"))
    end

    test "lists devices in alphabetical order", %{session: session} do
      session = visit(session, device_path(:index))

      assert_text(session, css(".device:nth-of-type(1)"), "device6")
      assert_text(session, css(".device:nth-of-type(2)"), "device7")
      assert_text(session, css(".device:nth-of-type(3)"), "device8")
    end

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
