defmodule DeviceTrackerWeb.Features.Api.MeasurementsTest do
  use DeviceTrackerWeb.FeatureCase, async: true

  alias DeviceTracker.Devices.Device

  describe "POST /devices/:id/measurements" do
    test "can create a measurement" do
      name = random_string()
      measurement = random_string()
      Device.add_device(name, [measurement])

      params = %{measurement: measurement, value: 123}
      path = device_measurement_path(:create, name)
      assert {:ok, %{status_code: 200, body: body}} = request(:post, path, Jason.encode!(params))

      assert {:ok, %{measurement: measurement, measurements: [123]}} ==
               Jason.decode(body, keys: :atoms)

      assert {:ok,
              %{
                measurements: %{String.to_atom(measurement) => %{measurements: [123]}},
                name: name,
                power_status: :on
              }} == Device.get(name)
    end
  end

  defp random_string() do
    :crypto.strong_rand_bytes(64) |> Base.url_encode64() |> binary_part(0, 64)
  end
end
