defmodule Onvif.Devices.GetServiceCapabilities do
  # import SweetXml
  import XmlBuilder
  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetServiceCapabilities"

  @spec request(Device.t(), :basic_auth | :digest_auth | :no_auth | :xml_auth) ::
          {:ok, any} | {:error, map()}
  def request(device, auth \\ :no_auth), do: Onvif.Devices.request(device, auth, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tds:GetServiceCapabilities")])
  end

  def response(xml_response_body) do
    xml_response_body
  end
end
