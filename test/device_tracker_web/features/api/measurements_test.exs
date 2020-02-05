defmodule DeviceTrackerWeb.Features.Api.MeasurementsTest do
  use DeviceTrackerWeb.FeatureCase, async: true

  alias DeviceTracker.Devices.Device

  describe "POST /devices/:id/measurements" do
    test "can create a measurement" do
      measurements = ["power_usage"]
      name =  "device4"
      Device.add_device(name, measurements)
      assert {:ok, %{measurements: %{power_usage: %{measurements: []}}}} = Device.get(name)

      params = %{measurement: "power_usage", value: 123}
      path = device_measurement_path(:create, name)
      assert {:ok, %{status_code: 200, body: body}} = request(:post, path, Jason.encode!(params))
      assert {:ok, %{measurement: "power_usage", measurements: [123]}} = Jason.decode(body, keys: :atoms)

      assert {:ok, %{measurements: %{power_usage: %{measurements: [123]}}}} = Device.get(name)
    end
  end
end
