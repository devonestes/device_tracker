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

  alias DeviceTracker.S3

  ### API

  def start_link({measurements, name}) do
    starting = fn ->
      %{
        name: name,
        measurements:
          Map.new(for key <- measurements, do: {String.to_atom(key), %{measurements: []}})
      }
    end

    name = {:via, Registry, {DeviceTracker.Registry, name}}
    Agent.start_link(starting, name: name)
  end

  def add_device(name, measurements) do
    {:ok, _} =
      DynamicSupervisor.start_child(
        DeviceTracker.DynamicSupervisor,
        {__MODULE__, {measurements, name}}
      )

    S3.put_bucket(name)
    {:ok, %{name: name, measurements: measurements}}
  end

  def add_measurement(name, measurement, value) do
    name
    |> pid_for()
    |> Agent.update(fn measurements ->
      measurements =
        update_in(
          measurements[:measurements][String.to_atom(measurement)][:measurements],
          &[value | &1]
        )

      S3.put_object(name, "measurements", :erlang.term_to_binary(measurements))
      measurements
    end)

    {:ok, measurements} = get_measurements(name, measurement)
    {:ok, %{measurement: measurement, measurements: measurements}}
  end

  def get_measurements(name, measurement) do
    measurements =
      name
      |> pid_for()
      |> Agent.get(& &1[:measurements][String.to_atom(measurement)][:measurements])

    {:ok, measurements}
  end

  def get(name) do
    case pid_for(name) do
      nil -> {:error, :not_found}
      pid -> {:ok, Agent.get(pid, & &1)}
    end
  end

  def list_all() do
    devices =
      DeviceTracker.Registry
      |> Registry.select([{{:"$1", :_, :_}, [], [:"$1"]}])
      |> Enum.flat_map(fn name ->
        case get(name) do
          {:ok, device} -> [device]
          _ -> []
        end
      end)

    {:ok, devices}
  end

  def update(name, settings) do
    case pid_for(name) do
      nil ->
        {:error, :device_not_found}

      pid ->
        settings =
          settings
          |> Enum.map(fn
            {k, v} when is_binary(k) -> {String.to_atom(k), v}
            {k, v} -> {k, v}
          end)
          |> Map.new()


        device =
          Agent.get_and_update(pid, fn state ->
            new_state = Map.merge(state, settings)
            {new_state, new_state}
          end)

        {:ok, device}
    end
  end

  def delete(name) do
    pid = pid_for(name)
    device = get(name)
    :ok = DynamicSupervisor.terminate_child(DeviceTracker.DynamicSupervisor, pid)
    :ok = Registry.unregister(DeviceTracker.Registry, name)
    device
  end

  def clear() do
    {:ok, devices} = list_all()
    Enum.map(devices, &delete(&1.name))
    :ok
  end

  ### PRIVATE FUNCTIONS

  defp pid_for(name) do
    case Registry.lookup(DeviceTracker.Registry, name) do
      [{pid, _} | _] -> pid
      _ -> nil
    end
  end
end
