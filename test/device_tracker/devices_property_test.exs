defmodule DeviceTracker.DevicesPropertyTest do
  use ExUnit.Case
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
      {_, _, run_result} = results = run_commands(__MODULE__, commands)

      (run_result == :ok)
      |> aggregate(command_names(commands))
      |> when_fail(PropCheck.StateM.print_report(results, commands, []))
    end
  end

  #########################################################################
  ### Callbacks for the state machine
  #########################################################################

  @impl true
  def initial_state() do
    Device.clear()
    []
  end

  def command_gen([]) do
    frequency([
      {1, {:list_all, []}},
      {3, {:add_device, [utf8(), list(utf8(100))]}}
    ])
  end

  def command_gen(names) do
    name_gen = such_that(name <- utf8(), when: name not in names)
    measurements_gen = list(utf8(100))

    frequency([
      {2, {:list_all, []}},
      {3, {:add_device, [name_gen, measurements_gen]}},
      {2, {:delete, [Enum.random(names)]}}
    ])
  end

  defcommand :list_all do
    def impl(), do: Device.list_all()

    def post(names, _, {:ok, devices}) do
      # Do this unsorted as a good example of a bug in a postcondition
      Enum.sort(names) == Enum.map(devices, & &1.name) |> Enum.sort()
    end
  end

  defcommand :add_device do
    def impl(name, measurements), do: Device.add_device(name, measurements, S3)
    def next(names, [name, _], _), do: [name | names]

    def post(_, [name, _], _) do
      {:ok, devices} = Device.list_all()
      name in Enum.map(devices, & &1.name)
    end
  end

  defcommand :delete do
    def impl(name), do: Device.delete(name)
    def next(names, [name], _), do: List.delete(names, name)

    def post(_, [name], _) do
      {:ok, devices} = Device.list_all()
      name not in Enum.map(devices, & &1.name)
    end
  end
end
