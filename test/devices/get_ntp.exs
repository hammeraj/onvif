defmodule Onvif.Devices.GetNTPTest do
  use ExUnit.Case, async: true

  alias Onvif.Devices.GetNTP
  alias Onvif.Devices.Schemas.NTP

  @moduletag capture_log: true

  describe "GetNTP/1" do
    test "check ntp configuration" do
      xml_response = File.read!("test/devices/fixtures/get_ntp_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, service_capabilities} = GetNTP.request(device)

      assert service_capabilities == %NTP{
               from_dhcp: false,
               ntp_from_dhcp: nil,
               ntp_manual: %NTP.NTPManual{
                 dns_name: "time.windows.com",
                 ipv4_address: nil,
                 ipv6_address: nil,
                 type: :dns
               }
             }
    end

    test "check a non-implemented GetNTP (dahua)" do
      xml_response = File.read!("test/devices/fixtures/invalid_get_ntp_response.xml")
      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, service_capabilities} = GetNTP.request(device)
      assert service_capabilities == nil
    end
  end
end
