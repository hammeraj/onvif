defmodule Onvif.Devices.GetNetworkInterfaces do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Device
  alias Onvif.Device.NetworkInterface

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetNetworkInterfaces"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device), do: Onvif.Devices.request(device, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tds:GetNetworkInterfaces")])
  end

  def response(xml_response_body) do
    response =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tds:GetNetworkInterfacesResponse/tds:NetworkInterfaces"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Enum.map(&NetworkInterface.parse/1)
      |> Enum.reduce([], fn raw_config, acc ->
        case NetworkInterface.to_struct(raw_config) do
          {:ok, config} ->
            [config | acc]

          {:error, changeset} ->
            Logger.error("Discarding invalid network interface: #{inspect(changeset)}")
            acc
        end
      end)

    {:ok, response}
  end
end
