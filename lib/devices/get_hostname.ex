defmodule Onvif.Devices.GetHostname do
  # import SweetXml
  import XmlBuilder

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetHostname"

  @spec request(Device.t(), :basic_auth | :digest_auth | :no_auth | :xml_auth) ::
          {:ok, any} | {:error, map()}
  def request(device, auth \\ :xml_auth), do: Onvif.Devices.request(device, auth, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tds:GetHostname")])
  end

  def response(xml_response_body) do
    xml_response_body
  end
end
