defmodule Onvif.Media.Ver20.GetVideoEncoderConfigurationOptionsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  alias Onvif.Media.Ver20.Schemas.Profile.VideoEncoderConfigurationOption

  describe "GetVideoEncoderConfigurationOptions/1" do
    test "should parse with correct values" do
      xml_response =
        File.read!("test/media/ver20/fixtures/get_video_encoder_configuration_options.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Media.Ver20.GetVideoEncoderConfigurationOptions.request(device, [])

      assert [
               %VideoEncoderConfigurationOption{
                 bitrate_range: %VideoEncoderConfigurationOption.BitrateRange{
                   max: 16384,
                   min: 32
                 },
                 constant_bit_rate_supported: true,
                 encoding: :h264,
                 frame_rates_supported: [
                   12.5,
                   12.0,
                   10.0,
                   8.0,
                   6.0,
                   4.0,
                   2.0,
                   1.0,
                   0.5,
                   0.25,
                   0.125,
                   0.0625
                 ],
                 gov_length_range: [1, 250],
                 guaranteed_frame_rate_supported: nil,
                 max_anchor_frame_distance: 0,
                 profiles_supported: ["Main", "High"],
                 quality_range: %VideoEncoderConfigurationOption.QualityRange{
                   max: 5,
                   min: 0
                 },
                 resolutions_available: [
                   %VideoEncoderConfigurationOption.ResolutionsAvailable{
                     height: 720,
                     width: 1280
                   },
                   %VideoEncoderConfigurationOption.ResolutionsAvailable{
                     height: 2160,
                     width: 3840
                   }
                 ]
               },
               %VideoEncoderConfigurationOption{
                 bitrate_range: %VideoEncoderConfigurationOption.BitrateRange{
                   max: 16384,
                   min: 32
                 },
                 constant_bit_rate_supported: true,
                 encoding: :h265,
                 frame_rates_supported: [
                   12.5,
                   12.0,
                   10.0,
                   8.0,
                   6.0,
                   4.0,
                   2.0,
                   1.0,
                   0.5,
                   0.25,
                   0.125,
                   0.0625
                 ],
                 gov_length_range: [1, 250],
                 guaranteed_frame_rate_supported: nil,
                 max_anchor_frame_distance: 0,
                 profiles_supported: ["Main"],
                 quality_range: %VideoEncoderConfigurationOption.QualityRange{
                   max: 5,
                   min: 0
                 },
                 resolutions_available: [
                   %VideoEncoderConfigurationOption.ResolutionsAvailable{
                     height: 1080,
                     width: 1920
                   },
                   %VideoEncoderConfigurationOption.ResolutionsAvailable{
                     height: 1440,
                     width: 2560
                   },
                   %VideoEncoderConfigurationOption.ResolutionsAvailable{
                     height: 1728,
                     width: 3072
                   }
                 ]
               }
             ] == response
    end

    test "should return error when response is invalid" do
      xml_response =
        File.read!(
          "test/media/ver20/fixtures/invalid_get_video_encoder_configuration_options.xml"
        )

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 400, body: xml_response}}
      end)

      {:error, %{status: status, reason: reason, response: response}} =
        Onvif.Media.Ver20.GetVideoEncoderConfigurationOptions.request(device)

      assert status == 400

      assert reason ==
               "Received 400 from Elixir.Onvif.Media.Ver20.GetVideoEncoderConfigurationOptions"

      assert response == xml_response
    end
  end
end
