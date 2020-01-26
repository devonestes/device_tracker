defmodule DeviceTrackerWeb.Api.MeasurementController do
  use DeviceTrackerWeb, :controller

  def create(conn, params) do
    json(conn, params)
  end
end
