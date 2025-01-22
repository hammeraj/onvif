defmodule Onvif.Media.Ver20.GetVideoSourceConfigurationsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetVideoSourceConfigurations/1" do
    test "should parse with correct values" do
      xml_response = File.read!("test/media/ver20/fixtures/get_video_source_configurations.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, [response]} = Onvif.Media.Ver20.GetVideoSourceConfigurations.request(device, [])

      assert %Onvif.Media.Ver10.Schemas.Profile.VideoSourceConfiguration{
               name: "user0",
               reference_token: "0",
               source_token: "0",
               use_count: 4,
               bounds: %Onvif.Media.Ver10.Schemas.Profile.VideoSourceConfiguration.Bounds{
                 height: 2160,
                 width: 3840,
                 x: 0,
                 y: 0
               }
             } == response
    end

    test "should return error when response is invalid" do
      xml_response =
        File.read!("test/media/ver20/fixtures/invalid_get_video_source_configurations.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 400, body: xml_response}}
      end)

      {:error, %{status: status, reason: reason, response: response}} =
        Onvif.Media.Ver20.GetVideoSourceConfigurations.request(device, ["1"])

      assert status == 400
      assert reason == "Received 400 from Elixir.Onvif.Media.Ver20.GetVideoSourceConfigurations"
      assert response == xml_response
    end
  end
end
