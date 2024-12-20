defmodule Onvif.Media.Ver10.GetProfilesTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetProfiles/1" do
    test "should exclude invalid video encoder payloads" do
      xml_response =
        File.read!(
          "test/media/ver10/fixtures/get_profiles_response_with_invalid_video_encoder.xml"
        )

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, profiles} = Onvif.Media.Ver10.GetProfiles.request(device)
      Enum.each(profiles, &assert(is_nil(&1.video_encoder_configuration)))
    end
  end
end
