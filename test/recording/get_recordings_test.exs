defmodule Onvif.Recording.GetRecordingsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetRecordings/1" do
    test "successfully get a list of recordings" do
      xml_response = File.read!("test/recording/fixture/get_recordings_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Recording.GetRecordings.request(device)

      assert Enum.map(response, fn r ->
               r.recording_token
             end) == [
               "SD_DISK_20200422_132655_67086B52",
               "SD_DISK_20200422_132613_45A883F5",
               "SD_DISK_20200422_123501_A2388AB3"
             ]
    end
  end
end
