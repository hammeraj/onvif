defmodule Onvif.Search.GetRecordingSearchResultsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  alias Onvif.Search.Schemas.GetRecordingSearchResults

  describe "GetRecordingSearchResults/2" do
    test "get recordings search results" do
      xml_response = File.read!("test/search/fixtures/get_recording_search_results_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} =
        Onvif.Search.GetRecordingSearchResults.request(device, %GetRecordingSearchResults{
          search_token: "RecordingSearchToken_1",
          max_results: 10,
          min_results: 2,
          wait_time: 5
        })

      assert response == %Onvif.Search.Schemas.FindRecordingResult{
               search_state: :completed,
               recording_information: [
                 %Onvif.Search.Schemas.RecordingInformation{
                   recording_token: "OnvifRecordingToken_1",
                   source: %Onvif.Search.Schemas.RecordingInformation.RecordingSourceInformation{
                     source_id: "SourceId_1",
                     name: "IpCamera_1",
                     location: "Location",
                     description: "Description of source",
                     address: "http://www.onvif.org/ver10/schema/Profile"
                   },
                   earliest_recording: ~U[1970-01-01 00:03:15Z],
                   latest_recording: ~U[2025-03-15 16:28:00Z],
                   content: "RecordContent",
                   tracks: [
                     %Onvif.Search.Schemas.RecordingInformation.TrackInformation{
                       track_token: "videotracktoken_1",
                       track_type: :video,
                       description: "VideoTrack",
                       data_from: ~U[1970-01-01 00:03:15Z],
                       data_to: ~U[2025-03-15 16:28:00Z]
                     },
                     %Onvif.Search.Schemas.RecordingInformation.TrackInformation{
                       track_token: "audiotracktoken_1",
                       track_type: :audio,
                       description: "AudioTrack",
                       data_from: ~U[1970-01-01 00:03:15Z],
                       data_to: ~U[2025-03-15 16:28:00Z]
                     },
                     %Onvif.Search.Schemas.RecordingInformation.TrackInformation{
                       track_token: "metadatatracktoken_1",
                       track_type: :metadata,
                       description: "MetadataTrack",
                       data_from: ~U[1970-01-01 00:03:15Z],
                       data_to: ~U[2025-03-15 16:28:00Z]
                     }
                   ],
                   recording_status: :stopped
                 }
               ]
             }
    end
  end
end
