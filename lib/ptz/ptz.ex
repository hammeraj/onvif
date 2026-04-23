defmodule Onvif.PTZ do
  @moduledoc """
    Interface for making requests to the Onvif PTZ(Pan/Tilt/Zoom) service

    https://www.onvif.org/onvif/ver20/ptz/wsdl/ptz.wsdl
  """
  require Logger

  alias Onvif.Device

  @namespaces [
    "xmlns:tt": "http://www.onvif.org/ver10/schema",
    "xmlns:tptz": "http://www.onvif.org/ver20/ptz/wsdl"
  ]

  @spec request(Device.t(), module()) :: {:ok, any} | {:error, map()}
  @spec request(Device.t(), any(), atom()) :: {:ok, any} | {:error, map()}
  def request(%Device{} = device, args \\ [], operation) do
    content = generate_content(operation, args)
    do_request(device, operation, content)
  end

  defp do_request(device, operation, content) do
    device
    |> Onvif.API.client(service_path: :ptz_ver20_service_path)
    |> Tesla.request(
      method: :post,
      headers: [{"Content-Type", "application/soap+xml"}, {"SOAPAction", operation.soap_action()}],
      body: %Onvif.Request{content: content, namespaces: @namespaces}
    )
    |> parse_response(operation)
  end

  defp generate_content(operation, []), do: operation.request_body()
  defp generate_content(operation, args), do: operation.request_body(args)

  defp parse_response({:ok, %{status: 200, body: body}}, operation) do
    operation.response(body)
  end

  defp parse_response({:ok, %{status: status_code, body: body}}, operation)
       when status_code >= 400,
       do:
         {:error,
          %{
            status: status_code,
            reason: "Received #{status_code} from #{operation}",
            response: body
          }}

  defp parse_response({:error, response}, operation) do
    {:error, %{status: nil, reason: "Error performing #{operation}", response: response}}
  end
end
