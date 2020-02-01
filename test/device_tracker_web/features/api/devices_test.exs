defmodule DeviceTrackerWeb.Features.Api.DevicesTest do
  use DeviceTrackerWeb.FeatureCase, async: true

  alias DeviceTracker.Devices.Device

  describe "POST /api/devices" do
    test "creates a new device" do
      name =  "device"
      params = %{name: name, measurements: ["power_usage"]}
      path = device_path(:create)
      assert {:ok, %{status_code: 200, body: body}} = request(:post, path, Jason.encode!(params))
      assert {:ok, ^params} = Jason.decode(body, keys: :atoms)
      assert {:ok, %{}} = Device.get(name)
    end
  end

  describe "PUT /devices/:id" do
    test "updates the configuration for a device" do
      measurements = ["power_usage"]
      name =  "device2"
      Device.add_device(name, measurements)

      params = %{power_status: "off"}
      path = device_path(:update, name)
      assert {:ok, %{status_code: 200, body: body}} = request(:put, path, Jason.encode!(params))
      assert {:ok, %{power_status: "off"}} = Jason.decode(body, keys: :atoms)
      assert {:ok, %{power_status: "off"}} = Device.get(name)
    end
  end

  describe "DELETE /devices/:id" do
    test "deletes a device" do
      measurements = ["power_usage"]
      name =  "device3"
      Device.add_device(name, measurements)

      path = device_path(:delete, name)
      assert {:ok, %{status_code: 200, body: body}} = request(:delete, path)
      assert %{} = Jason.decode!(body)
      assert {:error, :not_found} = Device.get(name)
    end
  end
end

