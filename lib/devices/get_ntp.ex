defmodule Onvif.Devices.GetNTP do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetNTP"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device) do
    Onvif.Devices.request(device, __MODULE__)
  end

  def request_body do
    element(:"s:Body", [element(:"tds:GetNTP")])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/tds:GetNTPResponse/tds:NTPInformation"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
    )
    |> Onvif.Devices.NTP.parse()
    |> Onvif.Devices.NTP.to_struct()
  end

end
