defmodule Onvif.Search.GetRecordingSummaryTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetRecordingSummary/0" do
    test "get an event search token" do
      xml_response = File.read!("test/search/fixtures/get_recording_summary__success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Search.GetRecordingSummary.request(device)

      assert response == %{
               data_from: "1970-01-01T00:00:00Z",
               data_until: "2024-12-13T08:08:49Z",
               number_recordings: "8"
             }
    end
  end
end
