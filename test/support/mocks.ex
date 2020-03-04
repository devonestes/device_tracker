defmodule DeviceTracker.ExAws.FakeHttp do
  @behaviour ExAws.Request.HttpClient

  @impl true
  def request(_method, _url, _body, _headers, _options) do
    {:ok, %{status_code: 200, body: ""}}
  end
end
