defmodule Onvif.Search.FindEventsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "FindEvents/2" do
    test "get an event search token" do
      xml_response = File.read!("test/search/fixtures/find_events__success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} =
        Onvif.Search.FindEvents.request(device, [
          ["Record_004"],
          "2024-12-06T19:00:00.0Z",
          "2024-12-06T19:02:00.0Z",
          "tns1:RecordingHistory/Track/State",
          "PT1M"
        ])

      assert response == "SearchToken[1]"
    end
  end
end
