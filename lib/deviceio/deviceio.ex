defmodule Onvif.DeviceIO do
  @moduledoc """
    Interface for making requests to the Onvif deviceio service


  """
  require Logger

  @endpoint "/onvif/deviceio"

  @namespaces [
    "xmlns:tmd": "http://www.onvif.org/ver10/deviceio/wsdl"
  ]

  @spec request(String.t(), list(), :basic_auth | :digest_auth | :no_auth | :xml_auth, module()) ::
          {:ok, any} | {:error, String.t()}
  def request(uri, args \\ [], auth \\ :xml_auth, operation) do
    content = generate_content(operation, args)
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

  defp generate_content(operation, args), do: apply(operation, :request_body, args)

  defp parse_response({:ok, %{status: 200, body: body}}, operation) do
    operation.response(body)
  end

  defp parse_response({:ok, response}, operation),
    do: {:error, "Received #{response.status} from #{operation}"}

  defp parse_response({:error, _response}, operation),
    do: {:error, "Error performing #{operation}"}
end
