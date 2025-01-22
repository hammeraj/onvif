defmodule Onvif.Devices.GetSystemDateAndTime do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Devices.Schemas.SystemDateAndTime

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetSystemDateAndTime"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device) do
    # Enforce no_auth for GetSystemDateAndTime to comply with ONVIF
    updated_device = %{device | auth_type: :no_auth}
    Onvif.Devices.request(updated_device, __MODULE__)
  end

  def request_body do
    element(:"s:Body", [element(:"tds:GetSystemDateAndTime")])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/tds:GetSystemDateAndTimeResponse/tds:SystemDateAndTime"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
    )
    |> SystemDateAndTime.parse()
    |> SystemDateAndTime.to_struct()
  end
end
