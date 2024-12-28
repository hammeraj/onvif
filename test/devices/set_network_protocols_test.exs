defmodule Onvif.Devices.SetNetworkProtocolsTest do
  use ExUnit.Case, async: true

  alias Onvif.Devices.NetworkProtocol

  @moduletag capture_log: true

  describe "SetNetworkProtocols/2" do
    test "should parse with correct values" do
      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: ""}}
      end)

      assert :ok =
               Onvif.Devices.SetNetworkProtocols.request(device, [
                 %NetworkProtocol{name: :rtsp, enabled: false, port: 8554}
               ])
    end
  end
end
