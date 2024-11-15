defmodule Onvif.Recording.GetReplayUri do
  import SweetXml
  import XmlBuilder
  require Logger

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/replay/wsdl/GetReplayUri"

  def request(device, args) do
    Onvif.Replay.request(device, args, __MODULE__)
  end

  def request_body(token) do
    element(:"s:Body", [
      element(:"trp:GetReplayUri", [
        element(:"tt:RecordingToken", token),
        element(:"tt:StreamSetup", [
          element(:"tt:Stream", "RTP-Unicast"),
          element(:"tt:Transport", [
            element(:"tt:Protocol", "RTSP")
         ])
       ])
      ])
    ])
  end

  def response(xml_response_body) do
    IO.puts xml_response_body
  end
end
