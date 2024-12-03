defmodule Onvif.Replay.GetServiceCapabilitiesTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetServiceCapabilities/1" do
    test "get service capabilities" do
      xml_response = File.read!("test/replay/fixtures/get_service_capabilities_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Replay.GetServiceCapabilities.request(device)

      assert response == %Onvif.Replay.ServiceCapabilities{
               dynamic_recordings: true,
               dynamic_tracks: false,
               max_string_length: "4096",
               media_profile_source: true,
               receive_source: false,
               reverse_playback: false,
               rtp_rtsp_tcp: true,
               rtsp_web_socket_uri: "",
               session_timeout_range: "0 4294967295"
             }
    end
  end
end
