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

  def request_body(%NTP{} = ntp) do
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
    case ntp_config.from_dhcp do
      false -> []
      true -> ntp_add_manual_element(ntp_config)
    end
  end

  def ntp_add_manual_element(%NTP{} = ntp_config) do
    [
      element(:"tds:Type", ntp_config.ntp_manual.type),
      ntp_manual_element_data(ntp_config.ntp_manual)
    ]
  end

  def ntp_manual_element_data(ntp_manual) do
    case ntp_manual.type do
      "IPv4" -> element(:"tt:IPv4Address", ntp_manual.ipv4_address)
      "IPv6" -> element(:"tt:IPv6Address", ntp_manual.ipv6_address)
      "DNS" -> element(:"tt:DNSname", ntp_manual.dns_name)
    end
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
