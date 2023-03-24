defmodule Onvif.DeviceIO.GetVideoSources do
  import SweetXml
  import XmlBuilder

  def soap_action, do: "http://www.onvif.org/ver10/deviceIO/wsdl/GetVideoSources"

  def request(uri, auth \\ :xml_auth), do: Onvif.DeviceIO.request(uri, auth, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tmd:GetVideoSources")])
  end

  def response(xml_response_body) do
    xml_response_body
  end
end
