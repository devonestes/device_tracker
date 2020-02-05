defmodule DeviceTrackerWeb.DeviceController do
  use DeviceTrackerWeb, :controller

  alias DeviceTracker.Devices.Device

  def index(conn, _params) do
    {:ok, devices} = Device.list_all()
    devices = Enum.reject(devices, fn device ->
      Enum.any?(device.measurements, fn {_, %{measurements: measurements}} ->
        measurements == []
      end)
    end)

    render(conn, "index.html", devices: devices)
  end

  def show(conn, params) do
    {:ok, device} = Device.get(params["id"])
    render(conn, "show.html", device: device)
  end
end
