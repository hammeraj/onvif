defmodule Onvif.Devices do
  @moduledoc """
    Interface for making requests to the Onvif devices service

    https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl
  """
  require Logger
  alias Onvif.Device

  @namespaces [
    "xmlns:tds": "http://www.onvif.org/ver10/device/wsdl"
  ]

  @spec request(Device.t(), :basic_auth | :digest_auth | :no_auth | :xml_auth, module()) ::
          {:ok, any} | {:error, map()}
  def request(%Device{} = device, auth \\ :xml_auth, operation) do
    content = generate_content(operation)
    soap_action = operation.soap_action()

    (device.address <> device.device_service_path)
    |> Onvif.API.client(auth)
    |> Tesla.request(
      method: :post,
      headers: [{"Content-Type", "application/soap+xml"}, {"SOAPAction", soap_action}],
      body: %Onvif.Request{content: content, namespaces: @namespaces}
    )
    |> parse_response(operation)
  end

  defp generate_content(operation), do: operation.request_body()

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
