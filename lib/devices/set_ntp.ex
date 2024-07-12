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
        element(:"tds:NTPManual", [
          List.flatten([ntp_manual_element(ntp)])
        ])
      ])
    ])
  end

  def ntp_manual_element(%NTP{} = ntp_config) do
    case ntp_config.ntp_manual do
      false -> []
      true -> ntp_add_manual_element(ntp_manual)
    end
  end

  def ntp_add_manual_element(%NTP.Manual{}=ntp_manual) do
    element(:"tds:Type", ntp_manual.type),
    case ntp_manual.type do
      "IPv4" -> ntp_ipv4_element(ntp_manual.address)
      "IPv6" -> ntp_ipv6_element(ntp_manual.address)
      "DNS"  -> ntp_dns_element(ntp_manual.address)
    end
  end

  def ntp_ipv4_element(%NTP.IPv4{}=ntp_ipv4) do
    element(:"tt:IPv4Address", ntp_ipv4.address)
  end
  def ntp_ipv6_element(%NTP.IPv6{}=ntp_ipv6) do
    element(:"tt:IPv6Address", ntp_ipv6.address)
  end
  def ntp_dns_element(%NTP.DNS{}=ntp_dns) do
    element(:"tt:DNSname", ntp_dns.name)
  end

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
