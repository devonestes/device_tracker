Application.put_env(:wallaby, :base_url, DeviceTrackerWeb.Endpoint.url())
{:ok, _} = Application.ensure_all_started(:mox)
{:ok, _} = Application.ensure_all_started(:wallaby)

Mox.defmock(DeviceTracker.ExAws.HttpMock, for: ExAws.Request.HttpClient)

ExUnit.start()
