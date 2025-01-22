defmodule Onvif.Media.Ver10.GetServiceCapabilitiesTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetServiceCapabilities/1" do
    test "should parse with correct values and defaults for non existing attributes" do
      xml_response = File.read!("test/media/ver10/fixtures/get_service_capabilities_response.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, service_capabilities} = Onvif.Media.Ver10.GetServiceCapabilities.request(device)

      assert service_capabilities == %Onvif.Media.Ver10.Schemas.ServiceCapabilities{
               exi_compression: false,
               osd: true,
               profile_capabilities:
                 %Onvif.Media.Ver10.Schemas.ServiceCapabilities.ProfileCapabilities{
                   maximum_number_of_profiles: 24
                 },
               rotation: false,
               snapshot_uri: true,
               streaming_capabilities:
                 %Onvif.Media.Ver10.Schemas.ServiceCapabilities.StreamingCapabilities{
                   no_rtsp_streaming: false,
                   non_aggregated_control: false,
                   rtp_rtsp_tcp: true,
                   rtp_tcp: false,
                   rtsp_multicast: false
                 },
               temporary_osd_text: false,
               video_source_mode: false
             }
    end
  end
end
