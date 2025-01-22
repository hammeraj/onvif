defmodule Onvif.Devices.GetNetworkProtocols do
  require Logger

  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Devices.Schemas.NetworkProtocol

  def soap_action(), do: "http://www.onvif.org/ver10/device/wsdl/GetNetworkProtocols"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device), do: Onvif.Devices.request(device, __MODULE__)

  def request_body() do
    element(:"s:Body", [element(:"tds:GetNetworkProtocols")])
  end

  def response(xml_response_body) do
    response =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tds:GetNetworkProtocolsResponse/tds:NetworkProtocols"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Enum.map(&NetworkProtocol.parse/1)
      |> Enum.reduce([], fn raw_config, acc ->
        case NetworkProtocol.to_struct(raw_config) do
          {:ok, config} ->
            [config | acc]

          {:error, changeset} ->
            Logger.error("Discarding invalid network protocol: #{inspect(changeset)}")
            acc
        end
      end)

    {:ok, response}
  end
end
