defmodule Onvif.Replay.GetServiceCapabilities do
  import SweetXml
  import XmlBuilder
  require Logger

  def soap_action, do: "http://www.onvif.org/ver10/replay/wsdl/GetServiceCapabilities"

  def request(device) do
    Onvif.Replay.request(device, __MODULE__)
  end

  def request_body() do
    element(:"s:Body", [
      element(:"trp:GetServiceCapabilities")
    ])
  end

  def response(xml_response_body) do
    doc = parse(xml_response_body, namespace_conformant: true, quiet: true)

    parsed_result =
      xpath(
        doc,
        ~x"//s:Envelope/s:Body/trp:GetServiceCapabilitiesResponse/trp:Capabilities"
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trp", "http://www.onvif.org/ver10/replay/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
        rtp_rtsp_tcp: ~x"//@RTP_RTSP_TCP"so,
        reverse_playback: ~x"//@ReversePlayback"so,
        session_timeout_range: ~x"//@SessionTimeoutRange"so,
        rtsp_web_socket_uri: ~x"//@RTSPWebSocketUri"so,
        receive_source: ~x"//tt:CapabilitiesExtension/RecordingCapabilities/@ReceiverSource"so,
        media_profile_source:
          ~x"//tt:CapabilitiesExtension/RecordingCapabilities/@MediaProfileSource"so,
        dynamic_recordings:
          ~x"//tt:CapabilitiesExtension/RecordingCapabilities/@DynamicRecordings"so,
        dynamic_tracks: ~x"//tt:CapabilitiesExtension/RecordingCapabilities/@DynamicTracks"so,
        max_string_length: ~x"//tt:CapabilitiesExtension/RecordingCapabilities/@MaxStringLength"so
      )

    {:ok, Onvif.Replay.ServiceCapabilities.from_parsed(parsed_result)}
  end
end
