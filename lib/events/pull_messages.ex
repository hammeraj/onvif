defmodule Onvif.Events.PullMessages do
  # import SweetXml
  import XmlBuilder

  alias Onvif.Device

  def soap_action,
    do: "http://www.onvif.org/ver10/events/wsdl/PullPointSubscription/PullMessagesRequest"

  @spec request(Device.t(), String.t()) :: {:ok, any} | {:error, map()}
  def request(device, endpoint),
    do: Onvif.Events.request(device, [endpoint: endpoint], __MODULE__)

  def request_body do
    element(:"s:Body", [
      element(:"tev:PullMessages", [
        element(:"tev:Timeout", ""),
        element(:"tev:MessageLimit", 100)
      ])
    ])
  end

  def response(xml_response_body) do
    xml_response_body
  end
end
