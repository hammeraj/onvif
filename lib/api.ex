defmodule Onvif.API do
  @moduledoc false

  @spec client(Onvif.Device.t(), Keyword.t()) :: Tesla.Client.t()
  def client(device, opts \\ [service_path: :device_service_path])

  def client(device, opts = [endpoint: uri]) do
    IO.inspect(opts)
    adapter = {Tesla.Adapter.Finch, name: Onvif.Finch}
    parsed_uri = URI.parse(uri)
    no_userinfo_uri = %URI{parsed_uri | userinfo: nil} |> URI.to_string()

    middleware = [
      {Tesla.Middleware.BaseUrl, no_userinfo_uri},
      auth_function(device),
      {Tesla.Middleware.Logger, log_level: :info},
      {Tesla.Middleware.Headers,
       [
         {"connection", "keep-alive"}
       ]}
    ]

    Tesla.client(middleware, adapter)
  end

  def client(device, opts) do
    adapter = {Tesla.Adapter.Finch, name: Onvif.Finch}
    service_path = get_service_path!(device, opts)

    uri = device.address <> service_path
    parsed_uri = URI.parse(uri)
    no_userinfo_uri = %URI{parsed_uri | userinfo: nil} |> URI.to_string()

    middleware = [
      {Tesla.Middleware.BaseUrl, no_userinfo_uri},
      auth_function(device),
      {Tesla.Middleware.Logger, log_level: :info},
      {Tesla.Middleware.Headers,
       [
         {"connection", "keep-alive"}
       ]}
    ]

    Tesla.client(middleware, adapter)
  end

  defp auth_function(%{auth_type: :no_auth}), do: Onvif.Middleware.NoAuth

  defp auth_function(%{auth_type: :basic_auth} = device),
    do: {Onvif.Middleware.PlainAuth, device: device}

  defp auth_function(%{auth_type: :xml_auth} = device),
    do: {Onvif.Middleware.XmlAuth, device: device}

  defp auth_function(%{auth_type: :digest_auth} = device),
    do: {Onvif.Middleware.DigestAuth, device: device}

  def get_service_path!(device, opts) do
    case Map.fetch!(device, opts[:service_path]) do
      nil -> raise "The service operation is not supported by the device"
      service_path -> service_path
    end
  end
end
