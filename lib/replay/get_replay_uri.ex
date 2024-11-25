defmodule Onvif.Replay.GetReplayUri do
  import SweetXml
  import XmlBuilder
  require Logger

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/replay/wsdl/GetReplayUri"

  def request(device, args) do
    Onvif.Replay.request(device, args, __MODULE__)
  end

  def request_body(token, ss_stream \\ "RTP-Unicast", ss_protocol \\ "TCP") do
    element(:"s:Body", [
      element(:"trp:GetReplayUri", [
        element(:"trp:StreamSetup", [
          element(:"tt:Stream", ss_stream),
          element(:"tt:Transport", [
            element(:"tt:Protocol", ss_protocol)
          ])
        ]),
        element(:"trp:RecordingToken", token)
      ])
    ])
  end

  def response(xml_response_body) do
    parsed_result =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//trp:Uri/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trp", "http://www.onvif.org/ver10/replay/wsdl")
      )

    {:ok, parsed_result}
  end
end
