defmodule Onvif.Media.Ver20.Media do
  @moduledoc """
  Interface for making requests to the 2.0 version of Onvif Media Service

  https://www.onvif.org/ver20/media/wsdl/media.wsdl
  """
  require Logger

  @endpoint "/onvif/media"

  @namespaces [
    "xmlns:tr2": "http://www.onvif.org/ver20/media/wsdl",
    "xmlns:tt": "http://www.onvif.org/ver10/schema"
  ]

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
