defmodule Onvif.Devices.SetNTPTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "SetNTP/1" do
    test "should parse with correct values" do
      xml_response = File.read!("test/devices/fixtures/set_ntp_request.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, service_capabilities} = Onvif.Devices.SetNTP.request(device, %Onvif.Devices.NTP{from_dhcp: true, ntp_manual: []})

      assert service_capabilities == %Onvif.Devices.NTP{
               from_dhcp: false,
               ntp_manual: [
                 type: "IPv4",
                 ipv4_address: "6.6.6.0"
               ]
             }
    end
  end
end
