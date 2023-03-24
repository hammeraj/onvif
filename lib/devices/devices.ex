defmodule Onvif.Devices do
  @moduledoc """
    Interface for making requests to the Onvif devices service

    https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl
  """
  require Logger

  @endpoint "/onvif/device_service"

  @namespaces [
    "xmlns:tds": "http://www.onvif.org/ver10/device/wsdl"
  ]

  @spec request(String.t(), :basic_auth | :digest_auth | :no_auth | :xml_auth, module()) :: {:ok, any} | {:error, String.t()}
  def request(uri, auth \\ :xml_auth, operation) do
    content = generate_content(operation)
    soap_action = operation.soap_action()

    (uri <> @endpoint)
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

  defp parse_response({:ok, response}, operation),
    do: {:error, "Received #{response.status} from #{operation}"}

  defp parse_response({:error, _response}, operation),
    do: {:error, "Error performing #{operation}"}
end
