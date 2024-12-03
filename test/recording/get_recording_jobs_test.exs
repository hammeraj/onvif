defmodule Onvif.Recording.GetRecordingJobsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetRecordingJobs/1" do
    test "get recording jobs" do
      xml_response = File.read!("test/recording/fixture/get_recording_jobs_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Recording.GetRecordingJobs.request(device)

      assert hd(response).job_token == "SD_DISK_20241120_211729_9C896594"
    end

    test "empty recording job" do
      xml_response = File.read!("test/recording/fixture/get_recording_jobs_empty.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Recording.GetRecordingJobs.request(device)

      assert response == []
    end
  end
end
