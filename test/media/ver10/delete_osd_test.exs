defmodule Onvif.Media.Ver10.DeleteOSDTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "DeleteOSD/1" do
    test "should delete the OSD for the device" do
      xml_response = File.read!("test/media/ver10/fixtures/delete_osd_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.Media.Ver10.DeleteOSD.request(device, ["token"])

      assert response == ""
    end

    test "should return an error when the OSD does not exist" do
      xml_response = File.read!("test/media/ver10/fixtures/delete_osd_nonexistent.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:error, %{status: 400, body: xml_response}}
      end)

      {:error, reason} = Onvif.Media.Ver10.DeleteOSD.request(device, ["token"])

      assert reason.reason == "Error performing Elixir.Onvif.Media.Ver10.DeleteOSD"
    end
  end
end
