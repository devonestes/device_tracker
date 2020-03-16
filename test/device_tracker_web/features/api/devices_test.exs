defmodule DeviceTrackerWeb.Features.Api.DevicesTest do
  use DeviceTrackerWeb.FeatureCase, async: true

  alias DeviceTracker.Devices.Device

  describe "POST /api/devices" do
    test "creates a new device" do
      name = random_string()
      measurement = random_string()
      params = %{name: name, measurements: [measurement]}
      path = device_path(:create)
      assert {:ok, %{status_code: 200, body: body}} = request(:post, path, Jason.encode!(params))
      assert {:ok, ^params} = Jason.decode(body, keys: :atoms)
      assert {:ok, %{name: ^name}} = Device.get(name)
    end
  end

  describe "PUT /devices/:id" do
    test "updates the configuration for a device" do
      name =  "device2"
      measurements = ["power_usage"]
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
      name =  "device3"
      measurements = ["power_usage"]
      Device.add_device(name, measurements)

      path = device_path(:delete, name)
      assert {:ok, %{status_code: 200, body: body}} = request(:delete, path)
      assert %{} = Jason.decode!(body)
      assert {:error, :not_found} = Device.get(name)
    end
  end

  defp random_string() do
    :crypto.strong_rand_bytes(64) |> Base.url_encode64() |> binary_part(0, 64)
  end
end
