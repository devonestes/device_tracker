defmodule DeviceTrackerWeb.Features.DevicesTest do
  use DeviceTrackerWeb.FeatureCase, async: true

  describe "GET /devices" do
    @tag :skip
    test "lists all devices", %{session: _session} do
      # Shows them in alphabetical
      # Groups devices if they're linked together
      # Groups with the fewest devices show up first in order
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
