defmodule Onvif.Replay.GetReplayUriTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetReplayUri/2" do
    test "get a replay uri" do
      xml_response = File.read!("test/replay/fixtures/get_replay_uri__success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} =
        Onvif.Replay.GetReplayUri.request(device, ["SD_DISK_20200422_132655_67086B52"])

      assert response ==
               "rtsp://192.168.1.136/onvif-media/record/play.amp?onvifreplayid=SD_DISK_20200422_132655_67086B52&onvifreplayext=1&streamtype=unicast&session_timeout=30"
    end

    test "get no uri" do
      xml_response = File.read!("test/replay/fixtures/get_replay_uri__recording_not_found.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Replay.GetReplayUri.request(device, ["SD_DISK_000"])

      assert response == ""
    end
  end
end
