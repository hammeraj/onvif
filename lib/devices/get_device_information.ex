defmodule Onvif.Devices.GetDeviceInformation do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetDeviceInformation"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device), do: Onvif.Devices.request(device, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tds:GetDeviceInformation")])
  end

  def response(xml_response_body) do
    doc = parse(xml_response_body, namespace_conformant: true, quiet: true)

    parsed_result =
      xpath(
        doc,
        ~x"//s:Envelope/s:Body/tds:GetDeviceInformationResponse"
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl"),
        manufacturer: ~x"./tds:Manufacturer/text()"s,
        model: ~x"./tds:Model/text()"s,
        firmware_version: ~x"./tds:FirmwareVersion/text()"s,
        serial_number: ~x"./tds:SerialNumber/text()"s,
        hardware_id: ~x"./tds:HardwareId/text()"s
      )

    {:ok, Map.merge(%Onvif.Devices.DeviceInformation{}, parsed_result)}
  end
end
