defmodule Onvif.Recording.CreateRecording do
  import SweetXml
  import XmlBuilder
  require Logger

  def soap_action, do: "http://www.onvif.org/ver10/recording/wsdl/CreateRecording"

  def request(device, args) do
    Onvif.Recording.request(device, args, __MODULE__)
  end

  def request_body(%{name: name, content: content, max_retention: max_retention}) do
    element(:"s:Body", [
      element(:"trc:CreateRecording", [
        element(:"trc:RecordingConfiguration", [
          element(:"tt:Source", [
            element(:"tt:SourceId", ""),
            element(:"tt:Name", name),
            element(:"tt:Location", ""),
            element(:"tt:Description", ""),
            element(:"tt:Address", "")
          ]),
          element(:"tt:Content", content),
          element(:"tt:MaximumRetentionTime", max_retention)
        ])
      ])
    ])
  end

  def response(xml_response_body) do
    response_uri =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trc:CreateRecordingResponse/trc:RecordingToken/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trc", "http://www.onvif.org/ver10/recording/wsdl")
      )

    {:ok, response_uri}
  end
end
