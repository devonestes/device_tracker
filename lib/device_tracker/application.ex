defmodule DeviceTracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      DeviceTrackerWeb.Endpoint,
      {DynamicSupervisor, strategy: :one_for_one, name: DeviceTracker.DynamicSupervisor},
      {Registry, keys: :unique, name: DeviceTracker.Registry}
    ]

    opts = [strategy: :one_for_one, name: DeviceTracker.Supervisor]
    return = Supervisor.start_link(children, opts)

    if Mix.env() == :dev, do: seeds()

    return
  end

  def config_change(changed, _new, removed) do
    DeviceTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp seeds() do
    devices = [
      {"lightbulb5", ["power_usage"]},
      {"lightbulb6", ["other_usage"]},
      {"lightbulb7", ["third_usage"]}
    ]

    Enum.each(devices, fn {name, measurements} ->
      DeviceTracker.Devices.Device.add_device(name, measurements)

      Enum.each(measurements, fn measurement ->
        DeviceTracker.Devices.Device.add_measurement(name, measurement, 123)
      end)
    end)
  end
end
