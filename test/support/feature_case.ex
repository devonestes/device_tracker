defmodule DeviceTrackerWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL
      alias DeviceTrackerWeb.{Endpoint, Router.Helpers}

      @endpoint Endpoint.url()

      defp device_path(method, args \\ [])

      defp device_path(method, name) when is_binary(name) do
        device_path(method, [name])
      end

      defp device_path(method, args) do
        apply(Helpers, :device_path, [Endpoint, method | args])
      end

      defp request(method, url, body, headers \\ [], options \\ []) do
        headers = [{"content-type", "application/json; charset=utf-8"} | headers]
        HTTPoison.request(method, @endpoint <> url, body, headers, options)
      end
    end
  end

  setup _tags do
    {:ok, session} = Wallaby.start_session()
    {:ok, session: session}
  end
end
