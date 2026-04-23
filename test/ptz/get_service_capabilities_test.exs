defmodule Onvif.PTZ.GetServiceCapabilitiesTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  alias Onvif.PTZ.Schemas.ServiceCapabilities

  describe "GetServiceCapabilities/1" do
    test "get service capabilities" do
      xml_response = File.read!("test/ptz/fixtures/get_service_capabilities_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.PTZ.GetServiceCapabilities.request(device)

      assert response == %ServiceCapabilities{
               eflip: false,
               reverse: false,
               get_compatible_configurations: true,
               move_status: true,
               status_position: true,
               move_and_track: []
             }
    end
  end
end
