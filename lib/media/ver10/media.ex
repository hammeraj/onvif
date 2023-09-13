defmodule Onvif.Media.Ver10.Media do
  @moduledoc """
  Interface for making requests to the 1.0 version of Onvif Media Service

  https://www.onvif.org/ver10/media/wsdl/media.wsdl
  """
  require Logger

  alias Onvif.Device

  @namespaces [
    "xmlns:trt": "http://www.onvif.org/ver10/media/wsdl",
    "xmlns:tt": "http://www.onvif.org/ver10/schema"
  ]

  @spec request(Device.t(), list, module()) :: {:ok, any} | {:error, map()}
  def request(%Device{} = device, args \\ [], operation) do
    content = generate_content(operation, args)
    soap_action = operation.soap_action()

    device
    |> Onvif.API.client(service_path: :media_service_path)
    |> Tesla.request(
      method: :post,
      headers: [{"Content-Type", "application/soap+xml"}, {"SOAPAction", soap_action}],
      body: %Onvif.Request{content: content, namespaces: @namespaces}
    )
    |> parse_response(operation)
  end

  defp generate_content(operation, args), do: apply(operation, :request_body, args)

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
