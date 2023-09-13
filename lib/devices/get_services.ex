defmodule Onvif.Devices.GetServices do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetServices"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device), do: Onvif.Devices.request(device, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tds:GetServices", [element(:"tds:IncludeCapability", "true")])])
  end

  def response(xml_response_body) do
    result =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tds:GetServicesResponse/tds:Service"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Enum.map(&Onvif.Device.Service.parse/1)
      |> Enum.map(&Onvif.Device.Service.to_struct/1)

    {:ok, result}
  end
end
