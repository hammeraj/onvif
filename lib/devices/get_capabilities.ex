defmodule Onvif.Devices.GetCapabilities do
  # import SweetXml
  import XmlBuilder

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetCapabilities"

  def request(uri, auth \\ :no_auth), do: Onvif.Devices.request(uri, auth, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tds:GetCapabilities")])
  end

  def response(xml_response_body) do
    xml_response_body
  end
end
