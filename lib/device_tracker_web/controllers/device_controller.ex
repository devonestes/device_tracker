defmodule DeviceTrackerWeb.DeviceController do
  use DeviceTrackerWeb, :controller

  alias DeviceTracker.Devices.Device

  def index(conn, _params) do
    {:ok, devices} = Device.list_all()
    render(conn, "index.html", devices: devices)
  end

  def show(conn, params) do
    device = Device.get(params["id"])
    render(conn, "show.html", device: device)
  end
end
