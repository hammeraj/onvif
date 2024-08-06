defmodule Onvif.Media.Ver10.GetOSDOptionsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetOSDOptions/1" do
    test "should get the OSDOptions for the device" do
      xml_response = File.read!("test/media/ver10/fixtures/get_osd_options_valid.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, osdoptions} = Onvif.Media.Ver10.GetOSDOptions.request(device, ["token"])

      assert osdoptions == %Onvif.Media.Ver10.OSDOptions{
               image_option: nil,
               maximum_number_of_osds: %Onvif.Media.Ver10.OSDOptions.MaximumNumberOfOSDs{
                 date: 1,
                 date_and_time: 1,
                 image: 4,
                 plaintext: 9,
                 time: 1,
                 total: 14
               },
               position_option: ["UpperLeft", "LowerLeft", "Custom"],
               text_option: %Onvif.Media.Ver10.OSDOptions.TextOption{
                 background_color: nil,
                 date_format: ["MM/dd/yyyy", "dd/MM/yyyy", "yyyy/MM/dd", "yyyy-MM-dd"],
                 font_color: %Onvif.Media.Ver10.OSDOptions.TextOption.FontColor{
                   color: %Onvif.Media.Ver10.OSDOptions.TextOption.FontColor.Color{
                     color_list: nil,
                     color_space_range: nil
                   },
                   transparent: nil
                 },
                 font_size_range: %Onvif.Media.Ver10.OSDOptions.TextOption.FontSizeRange{
                   max: 64,
                   min: 16
                 },
                 time_format: ["hh:mm:ss tt", "HH:mm:ss"],
                 type: ["Plain", "Date", "Time", "DateAndTime"]
               },
               type: ["Text"]
             }
    end
  end
end
