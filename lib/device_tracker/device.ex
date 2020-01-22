defmodule DeviceTracker.Device do
  use Agent

  ### API

  def add_device(name, measurements) do
    {:ok, _} = DynamicSupervisor.start_child(DeviceTracker.DynamicSupervisor, {__MODULE__, {measurements, name}})
    name
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
    |> Agent.get(&(&1[measurement]))
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
