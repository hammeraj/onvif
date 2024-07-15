defmodule Onvif.Devices.SetNTPTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "SetNTP/2" do
    test "check a dhcp-based ntp" do
      xml_response = File.read!("test/devices/fixtures/set_ntp_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, service_capabilities} = Onvif.Devices.SetNTP.request(device, %Onvif.Devices.NTP{from_dhcp: true})
      assert service_capabilities == ""
    end
    test "check a manual ntp" do
      xml_response = File.read!("test/devices/fixtures/set_ntp_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)
      {:ok, service_capabilities} = Onvif.Devices.SetNTP.request(device, %Onvif.Devices.NTP{from_dhcp: false, ntp_manual: %Onvif.Devices.NTP.NTPManual{type: "IPv4", ipv4_address: "6.6.6.0"}})
      assert service_capabilities == ""
    end
  end
end
