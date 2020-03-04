defmodule DeviceTracker.S3 do
  @moduledoc """
  An interface to all S3 interactions.
  """

  alias ExAws.S3

  def put_bucket(bucket) do
    put_bucket(bucket, "eu-west-1", [], [])
  end

  def put_bucket(bucket, options) when is_list(options) do
    put_bucket(bucket, "eu-west-1", options, [])
  end

  def put_bucket(bucket, region) do
    put_bucket(bucket, region, [], [])
  end

  def put_bucket(bucket, region, operation_options, request_options) do
    bucket
    |> S3.put_bucket(region, operation_options)
    |> ExAws.request(request_options)
    |> case do
      {:ok, %{status_code: 200}} -> :ok
      response -> {:error, response}
    end
  end

  def put_object(bucket, object, body, options \\ []) do
    bucket
    |> S3.put_object(object, body, options)
    |> ExAws.request()
  end
end
