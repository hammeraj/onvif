defmodule Onvif.Media.Ver10.GetVideoEncoderConfigurationOptionsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetVideoEncoderConfigurationOptions/1" do
    test "should get the VideoEncoderConfigurationOptions for the device" do
      xml_response =
        File.read!(
          "test/media/ver10/fixtures/get_video_encoder_configuration_options_response.xml"
        )

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Media.Ver10.GetVideoEncoderConfigurationOptions.request(device, [])

      assert response == [
               %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption{
                 extension: nil,
                 guranteed_frame_rate_supported: nil,
                 h264:
                   %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.H264Options{
                     encoding_interval_range:
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.H264Options.EncodingIntervalRange{
                         max: 6,
                         min: 1
                       },
                     frame_rate_range:
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.H264Options.FrameRateRange{
                         max: 25,
                         min: 1
                       },
                     gov_length_range:
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.H264Options.GovLengthRange{
                         max: 150,
                         min: 25
                       },
                     h264_profiles_supported: ["Baseline", "Main", "High"],
                     resolutions_available: [
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.H264Options.ResolutionsAvailable{
                         height: 576,
                         width: 704
                       },
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.H264Options.ResolutionsAvailable{
                         height: 480,
                         width: 640
                       },
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.H264Options.ResolutionsAvailable{
                         height: 288,
                         width: 352
                       }
                     ]
                   },
                 jpeg:
                   %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.JpegOptions{
                     encoding_interval_range:
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.JpegOptions.EncodingIntervalRange{
                         max: 6,
                         min: 1
                       },
                     frame_rate_range:
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.JpegOptions.FrameRateRange{
                         max: 25,
                         min: 1
                       },
                     resolutions_available: [
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.JpegOptions.ResolutionsAvailable{
                         height: 576,
                         width: 704
                       },
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.JpegOptions.ResolutionsAvailable{
                         height: 480,
                         width: 640
                       },
                       %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.JpegOptions.ResolutionsAvailable{
                         height: 288,
                         width: 352
                       }
                     ]
                   },
                 mpeg4: nil,
                 quality_range:
                   %Onvif.Media.Ver10.Schemas.Profile.VideoEncoderConfigurationOption.QualityRange{
                     max: 6,
                     min: 1
                   }
               }
             ]
    end
  end
end
