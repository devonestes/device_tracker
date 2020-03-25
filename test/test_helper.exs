{:ok, _} = Application.ensure_all_started(:mox)

Mox.defmock(DeviceTracker.ExAws.HttpMock, for: ExAws.Request.HttpClient)

ExUnit.start()
