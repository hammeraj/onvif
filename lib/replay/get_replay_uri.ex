defmodule Onvif.Replay.GetReplayUri do
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
        element(:"trp:StreamSetup", [
          element(:"tt:Stream", "RTP-Unicast"),
          element(:"tt:Transport", [
            element(:"tt:Protocol", "UDP")
          ])
        ]),
        element(:"trp:RecordingToken", token)
      ])
    ])
  end

  def response(xml_response_body) do
    doc = parse(xml_response_body, namespace_conformant: true, quiet: true)
    parsed_result =
      xpath(
        doc,
        ~x"//trp:Uri/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trp", "http://www.onvif.org/ver10/replay/wsdl")
      )

    IO.puts parsed_result
  end

end
