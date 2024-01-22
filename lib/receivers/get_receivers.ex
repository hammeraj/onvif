defmodule Onvif.Receivers.GetReceivers do
  # import SweetXml
  import XmlBuilder

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/receiver/wsdl/GetReceivers"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device), do: Onvif.Receivers.request(device, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tns1:GetReceivers")])
  end

  def response(xml_response_body) do
    xml_response_body
  end
end
