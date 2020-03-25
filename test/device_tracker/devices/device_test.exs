defmodule DeviceTracker.Devices.DeviceTest do
  use DeviceTracker.RegistryCase, async: true

  alias DeviceTracker.Devices.Device

  describe "add_device/2" do
    @tag :skip
    test "allows us to register a device" do
      name = random_string()
      measurement = random_string()

      assert {:ok, %{measurements: [^measurement], name: ^name}} =
               Device.add_device(name, [measurement])

      assert Registry.count(DeviceTracker.Registry) == 1
    end
  end

  describe "add_measurement/3" do
    test "allows us to add measurements" do
      name = random_string()
      measurement = random_string()
      assert {:ok, _} = Device.add_device(name, [measurement])

      assert {:ok, %{measurement: ^measurement, measurements: [1]}} =
               Device.add_measurement(name, measurement, 1)

      assert {:ok, %{measurement: ^measurement, measurements: [2, 1]}} =
               Device.add_measurement(name, measurement, 2)
    end

    test "uploads results to S3" do
    end
  end

  describe "get_measurements/2" do
    test "gets measurements for a given device" do
      name = random_string()
      measurement = random_string()
      assert {:ok, _} = Device.add_device(name, [measurement])
      assert {:ok, []} = Device.get_measurements(name, measurement)
      assert {:ok, _} = Device.add_measurement(name, measurement, 456)
      assert {:ok, [456]} = Device.get_measurements(name, measurement)
    end
  end

  describe "get/1" do
    test "gets all information for the given device" do
      name = random_string()
      measurement = random_string()
      assert {:ok, _} = Device.add_device(name, [measurement])
      assert {:ok, _} = Device.add_measurement(name, measurement, 456)

      measurement = String.to_atom(measurement)

      assert {:ok,
              %{
                name: name,
                measurements: %{measurement => %{measurements: [456]}},
                power_status: :on
              }} == Device.get(name)
    end

    test "returns an error tuple if the device doesn't exist" do
      assert {:error, :not_found} == Device.get("not_a_device")
    end
  end

  describe "list_all/0" do
    @tag :skip
    test "lists all information for all devices" do
      devices = Enum.map(0..2, fn _ -> {random_string(), [random_string()]} end)

      Enum.each(devices, fn {name, measurements} ->
        Device.add_device(name, measurements)
      end)

      assert {:ok, all_devices} = Device.list_all()

      devices
      |> Enum.map(fn {name, [measurement]} ->
        %{
          name: name,
          measurements: %{String.to_atom(measurement) => %{measurements: []}},
          power_status: :on
        }
      end)
      |> assert_lists_equal(all_devices, &assert_maps_equal(&1, &2, Map.keys(&2)))
    end
  end

  describe "update/2" do
    test "updates settings for the given device" do
      name = random_string()
      measurement = random_string()
      assert {:ok, _} = Device.add_device(name, [measurement])

      assert {:ok,
              %{
                power_status: :off,
                max_measurements: 10,
                group_name: "Living room"
              }} =
               Device.update(
                 name,
                 %{
                   :power_status => :off,
                   :max_measurements => 10,
                   "group_name" => "Living room"
                 }
               )
    end
  end

  describe "delete/1" do
    @tag :skip
    test "deletes the given device" do
      name = random_string()
      measurement = random_string()

      assert {:ok, _} = Device.add_device(name, [measurement])
      assert {:ok, _} = Device.delete(name)
      assert {:error, :not_found} = Device.get(name)
    end
  end

  defp random_string() do
    :crypto.strong_rand_bytes(64) |> Base.url_encode64() |> binary_part(0, 64)
  end
end
