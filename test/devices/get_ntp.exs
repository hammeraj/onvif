defmodule Onvif.Devices.GetNTPTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetNTP/1" do
    test "check ntp configuration" do
      xml_response = File.read!("test/devices/fixtures/get_ntp_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, service_capabilities} = Onvif.Devices.GetNTP.request(device)

      assert service_capabilities == %Onvif.Devices.NTP{
               from_dhcp: false,
               ntp_from_dhcp: nil,
               ntp_manual: %Onvif.Devices.NTP.NTPManual{
                 dns_name: "time.windows.com",
                 ipv4_address: nil,
                 ipv6_address: nil,
                 type: :dns
               }
             }
    end
  end
end
