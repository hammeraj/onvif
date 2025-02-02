defmodule Onvif.Search.FindRecordingsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  alias Onvif.Search.Schemas.FindRecordings

  describe "FindRecordings/2" do
    test "get a recordings search token" do
      xml_response = File.read!("test/search/fixtures/find_recordings_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} =
        Onvif.Search.FindRecordings.request(device, %FindRecordings{
          max_matches: 10,
          keep_alive_time: 5
        })

      assert response == "RecordingSearchToken_1"
    end
  end
end
