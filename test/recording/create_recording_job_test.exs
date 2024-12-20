defmodule Onvif.Recording.CreateRecordingJobTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "CreateRecordingJob/2" do
    test "create a recording" do
      xml_response = File.read!("test/recording/fixture/create_recording_job_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} =
        Onvif.Recording.CreateRecordingJob.request(device, [
          "SD_DISK_20241120_211729_9C896594",
          "9",
          "Active"
        ])

      assert response == "SD_DISK_20241120_211729_9C896594"
    end
  end
end
