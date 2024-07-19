defmodule Onvif.Devices.SetNTP do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Devices.NTP

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/SetNTP"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args) do
    Onvif.Devices.request(device, args, __MODULE__)
  end

  def request_body(config: %NTP{} = ntp) do
    element(:"s:Body", [
      element(:"tds:SetNTP", [
        element(:"tds:FromDHCP", ntp.from_dhcp),
        ntp_manual_element(ntp) |> List.flatten()
      ])
    ])
  end

  defp ntp_manual_element(%NTP{from_dhcp: true} = _ntp), do: []

  defp ntp_manual_element(%NTP{from_dhcp: false} = ntp) do
    [element(:"tds:NTPManual", ntp_add_manual_element(ntp.ntp_manual))]
  end

  defp ntp_add_manual_element(ntp_manual) do
    [
      element(
        :"tt:Type",
        Keyword.fetch!(Ecto.Enum.mappings(ntp_manual.__struct__, :type), ntp_manual.type)
      ),
      ntp_manual_element_data(ntp_manual)
    ]
  end

  defp ntp_manual_element_data(%NTP.NTPManual{type: :ipv4} = ntp_manual),
    do: element(:"tt:IPv4Address", ntp_manual.ipv4_address)

  defp ntp_manual_element_data(%NTP.NTPManual{type: :ipv6} = ntp_manual),
    do: element(:"tt:IPv6Address", ntp_manual.ipv6_address)

  defp ntp_manual_element_data(%NTP.NTPManual{type: :dns} = ntp_manual),
    do: element(:"tt:DNSname", ntp_manual.dns_name)

  def response(xml_response_body) do
    res =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tds:SetNTPResponse/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )

    {:ok, res}
  end
end
