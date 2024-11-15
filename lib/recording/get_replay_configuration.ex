
defmodule Onvif.Recording.GetServiceCapabilities do
  import SweetXml
  import XmlBuilder
  require Logger

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/replay/wsdl/GetServiceCapabilities"

  def request(device) do
    Onvif.Recordings.request(device, __MODULE__)
  end

  def request_body() do
    element(:"s:Body", [
      element(:"trp:GetServiceCapabilities")
    ])
  end

  def response(xml_response_body) do
    IO.puts xml_response_body
  end
end
