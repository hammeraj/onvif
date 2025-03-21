defmodule Onvif.Devices.SetNTPTest do
  use ExUnit.Case, async: true

  alias Onvif.Devices.Schemas.NTP
  alias Onvif.Devices.SetNTP

  @moduletag capture_log: true

  describe "SetNTP/2" do
    test "check a dhcp-based ntp" do
      xml_response = File.read!("test/devices/fixtures/set_ntp_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, service_capabilities} = SetNTP.request(device, config: %NTP{from_dhcp: true})

      assert service_capabilities == ""
    end

    test "check a manual ntp with IPv4" do
      xml_response = File.read!("test/devices/fixtures/set_ntp_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, service_capabilities} =
        SetNTP.request(device,
          config: %NTP{
            from_dhcp: false,
            ntp_manual: %NTP.NTPManual{type: :ipv4, ipv4_address: "6.6.6.0"}
          }
        )

      assert service_capabilities == ""
    end

    test "check a manual ntp with IPv6" do
      xml_response = File.read!("test/devices/fixtures/set_ntp_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, service_capabilities} =
        SetNTP.request(device,
          config: %NTP{
            from_dhcp: false,
            ntp_manual: %NTP.NTPManual{
              type: :ipv6,
              ipv6_address: "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
            }
          }
        )

      assert service_capabilities == ""
    end

    test "check a manual ntp with DNS" do
      xml_response = File.read!("test/devices/fixtures/set_ntp_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, service_capabilities} =
        SetNTP.request(device,
          config: %NTP{
            from_dhcp: false,
            ntp_manual: %NTP.NTPManual{type: :dns, dns_name: "ntp.example.com"}
          }
        )

      assert service_capabilities == ""
    end
  end
end
