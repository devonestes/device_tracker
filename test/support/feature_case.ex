defmodule DeviceTrackerWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL
      alias DeviceTrackerWeb.{Endpoint, Router.Helpers}

      @endpoint Endpoint.url()

      defp device_path(method, args \\ []) do
        apply(Helpers, :device_path, [Endpoint, method | args])
      end

      defp request(method, url, body, headers \\ [], options \\ []) do
        HTTPoison.request(method, @endpoint <> url, body, headers, options)
      end
    end
  end

  setup _tags do
    {:ok, session} = Wallaby.start_session()
    {:ok, session: session}
  end
end
