defmodule DeviceTracker.RegistryCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Assertions.Case
    end
  end

  setup _tags do
    Application.put_env(:device_tracker, :current_test_pid, self())

    random_string =
      :crypto.strong_rand_bytes(64) |> Base.url_encode64() |> binary_part(0, 64)

    registry = String.to_atom(random_string)

    DynamicSupervisor.start_child(
      DeviceTracker.DynamicSupervisor,
      {Registry, keys: :unique, name: registry}
    )

    {:ok, registry: registry}
  end
end
