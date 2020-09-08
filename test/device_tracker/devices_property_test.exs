defmodule DeviceTracker.DevicesPropertyTest do
  use ExUnit.Case, async: true
  use PropCheck
  use PropCheck.StateM.ModelDSL

  alias DeviceTracker.Devices.Device

  defmodule S3 do
    def put_bucket(_) do
      :ok
    end

    def put_object(_, _, _) do
      :ok
    end
  end

  property "does not raise any exceptions", numtests: 100, constraint_tries: 100 do
    forall commands <- commands(__MODULE__) do
      Process.put(:registry, start_registry())
      {_, _, run_result} = results = run_commands(__MODULE__, commands)

      (run_result == :ok)
      |> aggregate(command_names(commands))
      |> when_fail(PropCheck.StateM.print_report(results, commands, []))
    end
  end

  defp start_registry() do
    registry =
      :crypto.strong_rand_bytes(64)
      |> Base.url_encode64()
      |> binary_part(0, 64)
      |> String.to_atom()

    DynamicSupervisor.start_child(
      DeviceTracker.DynamicSupervisor,
      {Registry, keys: :unique, name: registry}
    )

    registry
  end

  #########################################################################
  ### Callbacks for the state machine
  #########################################################################

  @impl true
  def initial_state() do
    []
  end

  def command_gen([]) do
    frequency([
      {1, {:list_all, []}},
      {3, {:add_device, [utf8(), list(utf8())]}}
    ])
  end

  def command_gen(names) do
    name_gen = such_that(name <- utf8(), when: name not in names)
    measurements_gen = list(utf8())

    frequency([
      {1, {:list_all, [Process.get(:registry)]}},
      {3, {:add_device, [name_gen, measurements_gen, Process.get(:registry)]}},
      {2, {:delete, [Enum.random(names), Process.get(:registry)]}}
    ])
  end

  defcommand :list_all do
    def impl(), do: Device.list_all(Process.get(:registry))

    def post(names, _, {:ok, devices}) do
      # Do this unsorted as a good example of a bug in a postcondition
      Enum.sort(names) == devices |> Enum.map(& &1.name) |> Enum.sort()
    end
  end

  defcommand :add_device do
    def impl(name, measurements) do
      Device.add_device(name, measurements, S3, Process.get(:registry))
    end

    def post(_, [name, _], {:ok, _}) do
      {:ok, devices} = Device.list_all(Process.get(:registry))
      name in Enum.map(devices, & &1.name)
    end

    def post(_, _, _) do
      true
    end

    def next(names, [name, _], {:ok, _}), do: [name | names]
    def next(state, _, _), do: state
  end

  defcommand :delete do
    def impl(name, registry), do: Device.delete(name, registry)

    def post(_, [name], _) do
      {:ok, devices} = Device.list_all(Process.get(:registry))
      name not in Enum.map(devices, & &1.name)
    end

    def next(names, [name], _), do: List.delete(names, name)
  end
end
