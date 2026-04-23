defmodule Onvif.PTZ.GetStatusTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  alias Onvif.PTZ.Schemas.PTZStatus

  describe "GetStatus/1" do
    test "get ptz status" do
      xml_response = File.read!("test/ptz/fixtures/get_status_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.PTZ.GetStatus.request(device, "Profile_1")

      assert response == %PTZStatus{
               position: %Onvif.PTZ.Schemas.PTZVector{
                 pan_tilt: %Onvif.PTZ.Schemas.PTZVector.PanTilt{
                   x: 0.164178,
                   y: -0.618316,
                   space: "http://www.onvif.org/ver10/tptz/PanTiltSpaces/PositionGenericSpace"
                 },
                 zoom: 0.0
               },
               move_status: %Onvif.PTZ.Schemas.PTZStatus.MoveStatus{
                 pan_tilt: :idle,
                 zoom: :idle
               },
               utc_time: ~U[2025-04-05 20:37:31Z]
             }
    end
  end
end
