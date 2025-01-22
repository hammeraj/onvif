defmodule Onvif.Devices.GetDeviceInformation do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Device
  alias Onvif.Devices.Schemas.DeviceInformation

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetDeviceInformation"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device), do: Onvif.Devices.request(device, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tds:GetDeviceInformation")])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/tds:GetDeviceInformationResponse"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
    )
    |> DeviceInformation.parse()
    |> DeviceInformation.to_struct()
    |> case do
      {:ok, device_information} ->
        {:ok, device_information}

      {:error, changeset} ->
        Logger.error("Discarding invalid GetDeviceInformationResponse: #{inspect(changeset)}")
        {:ok, nil}
    end
  end
end
