defmodule Onvif.Events.GetEventProperties do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device

  def soap_action,
    do: "http://www.onvif.org/ver10/events/wsdl/EventPortType/GetEventPropertiesRequest"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device), do: Onvif.Events.request(device, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tev:GetEventProperties")])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/tev:GetEventPropertiesResponse"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tev", "http://www.onvif.org/ver10/events/wsdl")
      |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      |> add_namespace("wsa", "http://www.w3.org/2005/08/addressing")
      |> add_namespace("wsnt", "http://docs.oasis-open.org/wsn/b-2")
    )
  end
end
