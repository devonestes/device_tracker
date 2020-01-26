defmodule DeviceTrackerWeb.Api.DeviceController do
  use DeviceTrackerWeb, :controller

  alias DeviceTracker.Devices.Device

  def create(conn, params) do
    {:ok, device} = Device.add_device(params["name"], params["measurements"])
    json(conn, device)
  end

  def update(conn, params) do
    {:ok, device} = Device.update(params["name"], params["settings"])
    json(conn, device)
  end

  def delete(conn, params) do
    {:ok, device} = Device.delete(params["name"])
    json(conn, device)
  end
end
