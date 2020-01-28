defmodule DeviceTracker.Devices.Device do
  @moduledoc """
  Represents a device. A device looks something like this:

  %{
    name: "Lightbulb",
    group_name: "Living room",
    power_status: :on,
    max_measurements: 20,
    measurements: %{
      power_usage: %{
        measurements: [23, 13, 81, 15],
        max_measurements: 4,
        in_warning: false,
        warning_threshold: 50
      },
      amperage: %{
        measurements: [21, 19, 19, 21, 32, 10],
        max_measurements: 8,
        in_warning: false,
        warning_threshold: 35
    }
  }
  """

  use Agent

  ### API

  def add_device(name, measurements) do
    {:ok, _} =
      DynamicSupervisor.start_child(
        DeviceTracker.DynamicSupervisor,
        {__MODULE__, {measurements, name}}
      )

    {:ok, %{name: name, measurements: measurements}}
  end

  def add_measurement(name, measurement, value) do
    name
    |> pid_for()
    |> Agent.update(fn measurements ->
      update_in(measurements[measurement], &[value | &1])
    end)
  end

  def get_measurements(name, measurement) do
    name
    |> pid_for()
    |> Agent.get(& &1[measurement])
  end

  def get(name) do
    device =
      name
      |> pid_for()
      |> Agent.get(& &1)

    {:ok, device}
  end

  def list_all() do
    {:ok, [%{}]}
  end

  def update(name, settings) do
    settings =
      settings
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Map.new()

    pid = pid_for(name)

    device =
      Agent.get_and_update(pid, fn state ->
        new_state = Map.merge(settings, state)
        {new_state, new_state}
      end)

    {:ok, device}
  end

  def delete(name) do
    {:ok, %{}}
  end

  ### CALLBACKS

  def start_link({measurements, name}) do
    starting = fn -> Map.new(for key <- measurements, do: {key, []}) end
    name = {:via, Registry, {DeviceTracker.Registry, name}}
    Agent.start_link(starting, name: name)
  end

  defp pid_for(name) do
    [{pid, _}] = Registry.lookup(DeviceTracker.Registry, name)
    pid
  end
end
