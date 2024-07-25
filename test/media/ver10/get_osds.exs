defmodule Onvif.Media.Ver10.GetOSDsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetOSDs/1" do
    test "should list 2 OSDs" do
      xml_response = File.read!("test/media/ver10/fixtures/get_osds_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, osds} = Onvif.Media.Ver10.GetOSDs.request(device)

      assert length(osds) == 2

      assert hd(osds) == %Onvif.Media.Ver10.OSD{
               image: nil,
               position: %Onvif.Media.Ver10.OSD.Position{
                 pos: %{x: "0.454545", y: "-0.733333"},
                 type: :custom
               },
               text_string: %Onvif.Media.Ver10.OSD.TextString{
                 background_color: nil,
                 date_format: nil,
                 font_color: %Onvif.Media.Ver10.OSD.TextString.FontColor{
                   color: %{
                     colorspace: "http://www.onvif.org/ver10/colorspace/YCbCr",
                     x: "0.000000",
                     y: "0.000000",
                     z: "0.000000"
                   },
                   transparent: nil
                 },
                 font_size: 32,
                 is_persistent_text: nil,
                 plain_text: "Camera 01",
                 time_format: nil,
                 type: :plain
               },
               token: "OsdToken_100",
               type: :text,
               video_source_configuration_token: "VideoSourceToken"
             }
    end

    test "should have no OSD available" do
      xml_response = File.read!("test/media/ver10/fixtures/get_osds_empty.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, osds} = Onvif.Media.Ver10.GetOSDs.request(device)

      assert length(osds) == 0
    end
  end
end
