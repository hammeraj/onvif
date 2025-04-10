defmodule Onvif.Media.Ver10.SetOSDTest do
  alias Onvif.Media.Ver10.Schemas.OSD
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "SetOSDs/2" do
    test "should update the OSD" do
      xml_response = File.read!("test/media/ver10/fixtures/set_osd_response_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, osd} =
        Onvif.Media.Ver10.SetOSD.request(device, [
          %OSD{
            image: nil,
            position: %OSD.Position{
              pos: %{x: "-1.000000", y: "0.866667"},
              type: :custom
            },
            text_string: %OSD.TextString{
              background_color: nil,
              date_format: "MM/dd/yyyy",
              font_color: %OSD.TextString.FontColor{
                color: %{
                  colorspace: "http://www.onvif.org/ver10/colorspace/YCbCr",
                  x: "0.000000",
                  y: "0.000000",
                  z: "0.000000"
                },
                transparent: nil
              },
              font_size: 30,
              is_persistent_text: nil,
              plain_text: nil,
              time_format: "HH:mm:ss",
              type: :date_and_time
            },
            token: "OsdToken_101",
            type: :text,
            video_source_configuration_token: "VideoSourceToken"
          }
        ])

      assert osd == ""
    end

    test "shoud return an error" do
      xml_response = File.read!("test/media/ver10/fixtures/set_osd_response_error.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 500, body: xml_response}}
      end)

      {:error, error} =
        Onvif.Media.Ver10.SetOSD.request(device, [
          %OSD{
            position: %OSD.Position{
              pos: %{x: "-1.000000", y: "0.866667"},
              type: :custom
            },
            text_string: %OSD.TextString{
              date_format: "MM/dd/yyyy",
              font_color: %OSD.TextString.FontColor{
                color: %{
                  colorspace: "http://www.onvif.org/ver10/colorspace/YCbCr",
                  x: "0.000000",
                  y: "0.000000",
                  z: "0.000000"
                },
                transparent: nil
              },
              font_size: 30,
              time_format: "HH:mm:ss",
              type: :date_and_time
            },
            token: nil,
            type: :text,
            video_source_configuration_token: "VideoSourceToken"
          }
        ])

      assert error.reason == "Received 500 from Elixir.Onvif.Media.Ver10.SetOSD"
      assert String.contains?(error.response, "token is null")
    end
  end
end
