defmodule DeviceTracker.Unused do
  def not_called(arg) do
    arg + 1
    |> Map.get(:key)
    |> String.to_atom()
  end
end
