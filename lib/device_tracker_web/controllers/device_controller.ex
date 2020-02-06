defmodule DeviceTrackerWeb.DeviceController do
  use DeviceTrackerWeb, :controller

  alias DeviceTracker.Devices.Device

  def index(conn, _params) do
    {:ok, devices} = Device.list_all()

    devices =
      devices
      |> Enum.reject(fn device ->
        Enum.any?(device.measurements, fn {_, %{measurements: measurements}} ->
          measurements == []
        end)
      end)
      |> Enum.group_by(&Map.get(&1, :group_name))
      |> Enum.sort_by(&length(elem(&1, 1)), :desc)
      |> Enum.flat_map(fn {_, chunk} -> Enum.sort_by(chunk, & &1.name) end)

    render(conn, "index.html", devices: devices)
  end

  def show(conn, params) do
    {:ok, device} = Device.get(params["id"])
    render(conn, "show.html", device: device)
  end
end
