defmodule Onvif.Analytics do
  @moduledoc """
  Interface for making requests to the 1.0 version of Onvif Analytics Service

  https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl
  """
  import SweetXml
  require Logger

  alias Onvif.Device

  @namespaces [
    "xmlns:tan": "http://www.onvif.org/ver20/analytics/wsdl",
    "xmlns:tt": "http://www.onvif.org/ver10/schema"
  ]

  @spec request(Device.t(), list, module()) :: {:ok, any} | {:error, map()}
  def request(%Device{} = device, args \\ [], operation) do
    content = generate_content(operation, args)
    soap_action = operation.soap_action()

    device
    |> Onvif.API.client(service_path: :analytics_service_path)
    |> Tesla.request(
      method: :post,
      headers: [{"Content-Type", "application/soap+xml"}, {"SOAPAction", soap_action}],
      body: %Onvif.Request{content: content, namespaces: @namespaces}
    )
    |> parse_response(operation)
  end

  defp generate_content(operation, args), do: apply(operation, :request_body, args)

  defp parse_response({:ok, %{status: 200, body: body}}, operation) do
    body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(~x"//s:Envelope/s:Body/s:Fault"eo)
    |> case do
      nil ->
        operation.response(body)

      _ ->
        {:error,
         %{
           status: 200,
           reason: "Received a SOAP Fault from #{operation}",
           response: body
         }}
    end
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
