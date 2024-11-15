defmodule Onvif.Replay do
  @moduledoc """
    Interface for making requests to the Onvif recording service
    http://www.onvif.org/onvif/ver10/recording.wsdl
  """
  require Logger
  alias Onvif.Device

  @namespaces [
    "xmlns:trp": "http://www.onvif.org/ver10/replay/wsdl",
    "xmlns:tt": "http://www.onvif.org/ver10/schema"
  ]

  @spec request(Device.t(), module()) :: {:ok, any} | {:error, map()}
  def request(%Device{} = device, operation) do
    content = generate_content(operation)
    do_request(device, operation, content)
  end

  def request(%Device{} = device, args, operation) do
    content = generate_content(operation, args)
    do_request(device, operation, content)
  end

  defp do_request(device, operation, content) do
    device
    |> Onvif.API.client(service_path: :replay_service_path)
    |> Tesla.request(
      method: :post,
      headers: [{"Content-Type", "application/soap+xml"}, {"SOAPAction", operation.soap_action()}],
      body: %Onvif.Request{content: content, namespaces: @namespaces}
    )
    |> parse_response(operation)
  end

  defp generate_content(operation), do: operation.request_body()
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
