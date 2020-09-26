defmodule DeviceTrackerWeb.Features.DevicesTest do
  use DeviceTrackerWeb.FeatureCase, async: true

  alias DeviceTracker.Devices.Device

  describe "GET /devices" do
    test "lists devices in alphabetical order", %{session: session} do
    end

    test "groups devices, with groups sorted from largest to smallest", %{session: session} do
    end
  end

  describe "GET /devices/:id" do
    test "shows information for a single device", %{session: session} do
    end

    test "should not show data for a device if it is marked as off", %{session: session} do
    end
  end
end
