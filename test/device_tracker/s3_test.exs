defmodule Sketchql.Aws.S3Test do
  use ExUnit.Case, async: true

  alias Mox

  alias DeviceTracker.{ExAws.HttpMock, S3}

  describe "put_bucket/4" do
    test "makes the right calls to AWS" do
      Mox.expect(HttpMock, :request, &put_bucket/5)
      assert :ok == S3.put_bucket("test_bucket", "eu-west-1", [], http_client: HttpMock)
      Mox.verify!(HttpMock)
    end
  end

  defp put_bucket(method, url, body, headers, options) do
    assert method == :put
    assert url == "https://s3.amazonaws.com/test_bucket/"

    assert body == """
           <CreateBucketConfiguration xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\">
             <LocationConstraint>eu-west-1</LocationConstraint>
           </CreateBucketConfiguration>
           """

    assert [
             {"Authorization", _},
             {"host", "s3.amazonaws.com"},
             {"x-amz-date", _},
             {"content-length", 158},
             {"x-amz-content-sha256", _}
           ] = headers

    assert options == []
    {:ok, %{status_code: 200, body: ""}}
  end
end
