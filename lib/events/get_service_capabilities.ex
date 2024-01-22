defmodule Onvif.Events.GetServiceCapabilities do
  # import SweetXml
  import XmlBuilder
  alias Onvif.Device

  def soap_action,
    do: "http://www.onvif.org/ver10/events/wsdl/EventPortType/GetServiceCapabilitiesRequest"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device), do: Onvif.Events.request(device, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tev:GetServiceCapabilities")])
  end

  def response(xml_response_body) do
    xml_response_body
  end
end
