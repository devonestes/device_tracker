defmodule DeviceTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      DeviceTrackerWeb.Endpoint,
      {DynamicSupervisor, strategy: :one_for_one, name: DeviceTracker.DynamicSupervisor},
      {Registry, keys: :unique, name: DeviceTracker.Registry}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DeviceTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DeviceTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
