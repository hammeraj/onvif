defmodule Onvif.Recording.GetServiceCapabilitiesTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  alias Onvif.Recording.Schemas.ServiceCapabilities

  describe "GetServiceCapabilities/1" do
    test "get service capabilities" do
      xml_response = File.read!("test/recording/fixture/get_service_capabilities_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Recording.GetServiceCapabilities.request(device)

      assert response == %ServiceCapabilities{
               dynamic_tracks: false,
               dynamic_recordings: false,
               encoding: ["G711", "G726", "AAC", "H264", "JPEG", "H265"],
               max_rate: 16384.0,
               max_total_rate: 16384.0,
               max_recordings: 1.0,
               max_recording_jobs: 1.0,
               options: true,
               metadata_recording: false,
               supported_export_file_formats: [],
               event_recording: false,
               before_event_limit: nil,
               after_event_limit: nil,
               supported_target_formats: [],
               encryption_entry_limit: nil,
               supported_encryption_modes: []
             }
    end
  end
end
