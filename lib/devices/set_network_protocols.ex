defmodule Onvif.Devices.SetNetworkProtocols do
  require Logger

  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Devices.NetworkProtocol

  def soap_action(), do: "http://www.onvif.org/ver10/device/wsdl/SetNetworkProtocols"

  @spec request(Device.t(), list()) :: {:ok, any} | {:error, map()}
  def request(device, args), do: Onvif.Devices.request(device, args, __MODULE__)

  def request_body([network_protocols]) do
    network_protocols =
      List.wrap(network_protocols)
      |> Enum.map(fn network_protocol ->
        element(:"tds:NetworkProtocols", [
          element(
            :"tt:Name",
            Keyword.fetch!(Ecto.Enum.mappings(NetworkProtocol, :name), network_protocol.name)
          ),
          element(:"tt:Enabled", network_protocol.enabled),
          element(:"tt:Port", network_protocol.port)
        ])
      end)

    element(:"s:Body", [element(:"tds:SetNetworkProtocols", network_protocols)])
  end

  def response(_xml_response_body), do: :ok
end
