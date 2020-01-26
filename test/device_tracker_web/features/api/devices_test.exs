defmodule DeviceTrackerWeb.Features.Api.DevicesTest do
  use DeviceTrackerWeb.FeatureCase, async: true

  describe "POST /api/devices" do
    test "devices can be created" do
      params = %{name: "device"}
      path = device_path(:create)
      assert {:ok, _} = request(:post, path, Jason.encode!(params))
    end
  end

  describe "PUT /devices/:id" do
    @tag :skip
    test "updates the configuration for a device" do
    end
  end

  describe "DELETE /devices/:id" do
    @tag :skip
    test "deletes a device" do
    end
  end
end
