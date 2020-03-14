defmodule DeviceTracker.Devices.DeviceTest do
  use DeviceTracker.RegistryCase, async: true

  alias DeviceTracker.Devices.Device

  defmodule S3 do
    def put_bucket(name) do
      me = Application.get_env(:device_tracker, :current_test_pid)
      send(me, {:put_bucket, name})
    end

    def put_object(bucket, key, object) do
      pid = Application.get_env(:device_tracker, :current_test_pid)
      send(pid, {:put_object, bucket, key, object})
    end
  end

  describe "add_device/2" do
    test "allows us to register a device", %{registry: registry} do
      name = "lightbulb"
      measurement = "power_used"

      assert {:ok, %{measurements: ["power_used"], name: "lightbulb"}} =
               Device.add_device(name, [measurement], S3, registry)

      assert Registry.count(registry) >= 1
    end

    test "creates an S3 bucket", %{registry: registry} do
      name = "lightbulb_again"
      measurement = "power_used"
      Device.add_device(name, [measurement], S3, registry)
      assert_receive({:put_bucket, ^name})
    end
  end

  describe "add_measurement/3" do
    test "allows us to add measurements", %{registry: registry} do
      name = "lightbulb2"
      measurement = "power_used"
      assert {:ok, _} = Device.add_device(name, [measurement], S3, registry)

      assert {:ok, %{measurement: "power_used", measurements: [1]}} =
               Device.add_measurement(name, measurement, 1, S3, registry)

      assert {:ok, %{measurement: "power_used", measurements: [2, 1]}} =
               Device.add_measurement(name, measurement, 2, S3, registry)
    end

    test "uploads results to S3", %{registry: registry} do
      name = "lightbulb2_again"
      measurement = "power_used"
      Device.add_device(name, [measurement], S3, registry)
      Device.add_measurement(name, measurement, 1, S3, registry)

      expected_state = %{
        measurements: %{power_used: %{measurements: [1]}},
        name: "lightbulb2_again",
        power_status: :on
      }

      expected_binary = :erlang.term_to_binary(expected_state)
      assert_received({:put_object, ^name, "measurements", ^expected_binary})
    end
  end

  describe "get_measurements/2" do
    test "gets measurements for a given device", %{registry: registry} do
      name = "lightbulb3"
      measurement = "power_used"
      assert {:ok, _} = Device.add_device(name, [measurement], S3, registry)
      assert {:ok, []} = Device.get_measurements(name, measurement, registry)
      assert {:ok, _} = Device.add_measurement(name, measurement, 456, S3, registry)
      assert {:ok, [456]} = Device.get_measurements(name, measurement, registry)
    end
  end

  describe "get/1" do
    test "gets all information for the given device", %{registry: registry} do
      name = "lightbulb4"
      measurement = "power_used"
      assert {:ok, _} = Device.add_device(name, [measurement], S3, registry)
      assert {:ok, _} = Device.add_measurement(name, measurement, 456, S3, registry)
      assert {:ok, %{}} = Device.get(name, registry)
    end

    test "returns an error tuple if the device doesn't exist", %{registry: registry} do
      assert {:error, :not_found} == Device.get("not_a_device", registry)
    end
  end

  describe "list_all/0" do
    test "lists all information for all devices", %{registry: registry} do
      devices = [
        {"lightbulb5", ["power_usage"]},
        {"lightbulb6", ["other_usage"]},
        {"lightbulb7", ["third_usage"]}
      ]

      Enum.each(devices, fn {name, measurements} ->
        Device.add_device(name, measurements, S3, registry)
      end)

      assert {:ok, all_devices} = Device.list_all(registry)

      devices
      |> Enum.map(fn {name, _} -> %{name: name} end)
      |> assert_lists_equal(all_devices, fn left, right ->
        assert_maps_equal(left, right, [:name])
      end)
    end
  end

  describe "update/2" do
    test "updates settings for the given device", %{registry: registry} do
      name = "lightbulb8"
      measurement = "power_used"
      assert {:ok, _} = Device.add_device(name, [measurement], S3, registry)

      assert {:ok,
              %{
                power_status: :off,
                max_measurements: 10,
                group_name: "Living room"
              }} =
               Device.update(name, %{
                 :power_status => :off,
                 :max_measurements => 10,
                 "group_name" => "Living room"
               }, registry)
    end
  end

  describe "delete/1" do
    test "deletes the given device", %{registry: registry} do
      name = "lightbulb9"
      measurement = "power_used"

      assert {:ok, _} = Device.add_device(name, [measurement], S3, registry)
      assert {:ok, %{}} = Device.get(name, registry)
      assert {:ok, _} = Device.delete(name, registry)
      assert {:error, :not_found} = Device.get(name, registry)
    end
  end
end
