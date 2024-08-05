defmodule Onvif.Media.Ver10.CreateOSDTest do
  alias Onvif.Media.Ver10.OSD
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "CreateOSDs/2" do
    test "should create an OSD and return the token" do
      xml_response = File.read!("test/media/ver10/fixtures/create_osd_response_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, osdtoken} =
        Onvif.Media.Ver10.CreateOSD.request(device, [
          %OSD{
            image: nil,
            position: %OSD.Position{
              pos: %{x: "0.666000", y: "0.666000"},
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
            token: "",
            type: :text,
            video_source_configuration_token: "VideoSourceToken"
          }
        ])

      assert osdtoken == "OsdToken_102"
    end

    test "should not create an OSD as it reached the maximum amount of OSDs" do
      xml_response = File.read!("test/media/ver10/fixtures/create_osd_response_maxosd.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, osd} =
        Onvif.Media.Ver10.CreateOSD.request(device, [
          %OSD{
            image: nil,
            position: %OSD.Position{
              pos: %{x: "0.666000", y: "0.666000"},
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
            token: "",
            type: :text,
            video_source_configuration_token: "VideoSourceToken"
          }
        ])

      assert osd == ""
    end
  end
end
