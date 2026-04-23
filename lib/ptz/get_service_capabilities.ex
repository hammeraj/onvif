defmodule Onvif.PTZ.GetServiceCapabilities do
  @moduledoc """
  Returns the capabilities of the PTZ service.
  """

  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.PTZ.Schemas.ServiceCapabilities

  def soap_action(), do: "http://www.onvif.org/ver20/ptz/wsdl/GetServiceCapabilities"

  @spec request(Device.t()) :: {:ok, any()} | {:error, map()}
  def request(device), do: Onvif.PTZ.request(device, __MODULE__)

  def request_body(), do: element(:"s:Body", [:"tptz:GetServiceCapabilities"])

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/tptz:GetServiceCapabilitiesResponse/tptz:Capabilities"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      |> add_namespace("tptz", "http://www.onvif.org/ver20/ptz/wsdl")
    )
    |> ServiceCapabilities.parse()
    |> ServiceCapabilities.to_struct()
  end
end
