defmodule Onvif.Recording.GetServiceCapabilities do
  @moduledoc """
  Returns the capabilities of the recording service.
  """

  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Recording.Schemas.ServiceCapabilities

  def soap_action(), do: "http://www.onvif.org/ver10/recording/wsdl/GetServiceCapabilities"

  @spec request(Device.t()) :: {:ok, any()} | {:error, map()}
  def request(device), do: Onvif.Recording.request(device, __MODULE__)

  def request_body(), do: element(:"s:Body", [:"trc:GetServiceCapabilities"])

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/trc:GetServiceCapabilitiesResponse/trc:Capabilities"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      |> add_namespace("trc", "http://www.onvif.org/ver10/recording/wsdl")
    )
    |> ServiceCapabilities.parse()
    |> ServiceCapabilities.to_struct()
  end
end
