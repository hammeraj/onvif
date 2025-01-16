defmodule Onvif.Devices.GetNetworkProtocolsTest do
  use ExUnit.Case, async: true

  alias Onvif.Devices.NetworkProtocol

  @moduletag capture_log: true

  describe "GetNetworkProtocols/1" do
    test "should parse with correct values" do
      xml_response = File.read!("test/devices/fixtures/get_network_protocols.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, network_protocols} = Onvif.Devices.GetNetworkProtocols.request(device)

      assert network_protocols == [
               %NetworkProtocol{name: :rtsp, enabled: true, port: 554},
               %NetworkProtocol{name: :https, enabled: false, port: 443},
               %NetworkProtocol{name: :http, enabled: true, port: 80}
             ]
    end

    test "should return error when response is invalid" do
      xml_response =
        File.read!("test/devices/fixtures/invalid_get_network_protocols_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 400, body: xml_response}}
      end)

      {:error, %{status: status, reason: reason, response: response}} =
        Onvif.Devices.GetNetworkProtocols.request(device)

      assert status == 400
      assert reason == "Received 400 from Elixir.Onvif.Devices.GetNetworkProtocols"
      assert response == xml_response
    end
  end
end
