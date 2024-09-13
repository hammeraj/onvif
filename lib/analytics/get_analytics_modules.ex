defmodule Onvif.Analytics.GetAnalyticsModules do
  # import SweetXml
  import XmlBuilder

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver20/analytics/wsdl/GetAnalyticsModules"

  @spec request(Device.t(), list()) :: {:ok, any} | {:error, map()}
  def request(device, args), do: Onvif.Analytics.request(device, args, __MODULE__)

  def request_body(configuration_token) do
    element(:"s:Body", [element(:"tan:GetAnalyticsModules", [element(:"tan:ConfigurationToken", configuration_token)])])
  end

  def response(xml_response_body) do
    xml_response_body
  end
end
