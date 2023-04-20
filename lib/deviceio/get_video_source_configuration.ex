defmodule Onvif.DeviceIO.GetVideoSourceConfiguration do
  # import SweetXml
  import XmlBuilder

  def soap_action, do: "http://www.onvif.org/ver10/deviceio/wsdl/GetVideoSourceConfiguration"

  def request(uri, args, auth \\ :xml_auth), do: Onvif.DeviceIO.request(uri, args, auth, __MODULE__)

  def request_body(video_source_token) do
    element(:"s:Body", [element(:"tmd:GetVideoSourceConfiguration", [element(:"tmd:VideoSourceToken", video_source_token)])])
  end

  def response(xml_response_body) do
    xml_response_body
  end
end
