defmodule DeviceTracker.DevicesPropertyTest do
  use ExUnit.Case
  use PropCheck
  use PropCheck.StateM.ModelDSL
  import Assertions

  alias DeviceTracker.Devices.Device

  defmodule S3 do
    def put_bucket(_) do
      :ok
    end

    def put_object(_, _, _) do
      :ok
    end
  end

  @tag :skip
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

  def command_gen(_model) do
    frequency([
      {1, {:list_all, []}},
      {3, {:add_device, [utf8(), list(utf8())]}}
    ])
  end

  defcommand :list_all do
    def impl(), do: Device.list_all()

    def post(model, _, {:ok, devices}) do
      devices |> Enum.map(& &1.name) |> assert_lists_equal(model)
    end
  end

  defcommand :add_device do
    def impl(name, measurements) do
      Device.add_device(name, measurements)
    end

    def post(_, [name, _], {:ok, _}) do
      {:ok, devices} = Device.list_all()
      Enum.any?(devices, fn device -> device.name == name end)
    end

    def post(_, _, _) do
      true
    end

    def next(model, [name, _], {:ok, _}), do: [name | model]
    def next(model, _, _), do: model
  end
end
