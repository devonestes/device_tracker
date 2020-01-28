defmodule DeviceTrackerWeb.Router do
  use DeviceTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DeviceTrackerWeb do
    pipe_through :browser
    resources "/devices", DeviceController, only: [:index, :show]
  end

  scope "/api", DeviceTrackerWeb.Api do
    pipe_through :api
    resources "/devices", DeviceController, only: [:create, :update, :delete] do
      resources "/measurements", MeasurementController, only: [:create]
    end
  end
end
