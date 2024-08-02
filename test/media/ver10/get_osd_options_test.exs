defmodule Onvif.Media.Ver10.GetOSDOptionsTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetOSDOptions/1" do
    test "should get the OSDOptions for the devioce" do
      xml_response = File.read!("test/media/ver10/fixtures/get_osd_options_valid.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, osdoptions} = Onvif.Media.Ver10.GetOSDOptions.request(device, ["token"])

      assert osdoptions == ""
    end
  end
end
