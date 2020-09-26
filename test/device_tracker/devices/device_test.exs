defmodule DeviceTracker.Devices.DeviceTest do
  use DeviceTracker.RegistryCase, async: true

  alias DeviceTracker.Devices.Device

  describe "add_device/2" do
    test "allows us to register a device" do
      name = random_string()
      measurement = random_string()

      assert {:ok, %{measurements: [^measurement], name: ^name}} =
               Device.add_device(name, [measurement])

      assert Registry.count(DeviceTracker.Registry) == 1

      assert {:ok, %{name: ^name, measurements: measurements, power_status: :on}} =
               Device.get(name)

      assert Map.fetch!(measurements, String.to_atom(measurement)) == %{measurements: []}
    end
  end

  describe "add_measurement/3" do
    test "allows us to add measurements" do
    end

    test "uploads results to S3" do
    end
  end

  describe "get_measurements/2" do
    test "gets measurements for a given device" do
    end
  end

  describe "get/1" do
    test "gets all information for the given device" do
    end

    test "returns an error tuple if the device doesn't exist" do
    end
  end

  describe "list_all/0" do
    test "lists all information for all devices" do
    end
  end

  describe "update/2" do
    test "updates settings for the given device" do
    end
  end

  describe "delete/1" do
    test "deletes the given device" do
    end
  end

  defp random_string() do
    :crypto.strong_rand_bytes(64) |> Base.url_encode64() |> binary_part(0, 64)
  end
end
