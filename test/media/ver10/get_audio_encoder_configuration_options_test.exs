defmodule Onvif.Media.Ver10.GetAudioEncoderConfigurationOptionsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetAudioEncoderConfigurationOptions/1" do
    test "should get the AudioEncoderConfigurationOptions for the device" do
      xml_response =
        File.read!(
          "test/media/ver10/fixtures/get_audio_encoder_configuration_options_response.xml"
        )

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Media.Ver10.GetAudioEncoderConfigurationOptions.request(device)

      assert response == [
               %Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption{
                 options: [
                   %Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption.Options{
                     bitrate_list:
                       %Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption.Options.BitrateList{
                         items: [32]
                       },
                     encoding: :G711,
                     sample_rate_list:
                       %Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption.Options.SampleRateList{
                         items: [8]
                       }
                   },
                   %Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption.Options{
                     bitrate_list:
                       %Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption.Options.BitrateList{
                         items: [32]
                       },
                     encoding: :G726,
                     sample_rate_list:
                       %Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption.Options.SampleRateList{
                         items: [8]
                       }
                   },
                   %Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption.Options{
                     bitrate_list:
                       %Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption.Options.BitrateList{
                         items: [32, 64]
                       },
                     encoding: :AAC,
                     sample_rate_list:
                       %Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption.Options.SampleRateList{
                         items: [8, 16]
                       }
                   }
                 ]
               }
             ]
    end

    test "should have not config for the token" do
      xml_response =
        File.read!(
          "test/media/ver10/fixtures/get_audio_encoder_configuration_options_nonexistent.xml"
        )

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:error, %{status: 500, body: xml_response}}
      end)

      {:error, response} =
        Onvif.Media.Ver10.GetAudioEncoderConfigurationOptions.request(device, ["random", nil])

      assert response.reason ==
               "Error performing Elixir.Onvif.Media.Ver10.GetAudioEncoderConfigurationOptions"

      assert String.contains?(
               response.response.body,
               "The requested configuration does not exist"
             )
    end

    test "should not support the configuration options" do
      xml_response =
        File.read!(
          "test/media/ver10/fixtures/get_audio_encoder_configuration_options_notsupport.xml"
        )

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:error, %{status: 500, body: xml_response}}
      end)

      {:error, response} =
        Onvif.Media.Ver10.GetAudioEncoderConfigurationOptions.request(device, [nil, nil])

      assert response.reason ==
               "Error performing Elixir.Onvif.Media.Ver10.GetAudioEncoderConfigurationOptions"

      assert String.contains?(response.response.body, "The NVT does not support audio")
    end
  end
end
