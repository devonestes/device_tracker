defmodule DeviceTrackerWeb.Api.MeasurementController do
  use DeviceTrackerWeb, :controller

  alias DeviceTracker.Devices.Device

  def create(conn, params) do
    {:ok, resp} =
      Device.add_measurement(params["device_id"], params["measurement"], params["value"])

    json(conn, resp)
  end
end
