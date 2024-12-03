defmodule Onvif.Recording.CreateRecordingTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "CreateRecording/2" do
    test "create a recording" do
      xml_response = File.read!("test/recording/fixture/create_recording_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response_uri} = Onvif.Recording.CreateRecording.request(
        device,
        config: %Onvif.Recording.Recording.Configuration{
            content: "test",
            maximum_retention_time: "PT1H",
            source: %Onvif.Recording.Recording.Configuration.Source{
              name: "test",
            }
          })

      assert response_uri == "SD_DISK_20200422_123501_A2388AB3"
    end
  end
end
