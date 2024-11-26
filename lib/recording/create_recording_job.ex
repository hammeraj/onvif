defmodule Onvif.Recording.CreateRecordingJob do
  import SweetXml
  import XmlBuilder
  require Logger

  def soap_action, do: "http://www.onvif.org/ver10/recording/wsdl/CreateRecordingJob"

  def request(device, args) do
    Onvif.Recording.request(device, args, __MODULE__)
  end

  def request_body(recording_token, priority \\ "0", mode \\ "Active") do
    element(:"s:Body", [
      element(:"trc:CreateRecordingJob", [
        element(:"trc:JobConfiguration", [
          element(:"tt:RecordingToken", recording_token),
          element(:"tt:Mode", mode),
          element(:"tt:Priority", priority)
        ])
      ])
    ])
  end

  def response(xml_response_body) do
    parsed_result =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trc:CreateRecordingJobResponse"
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trc", "http://www.onvif.org/ver10/recording/wsdl"),
        job_token: ~x"//trc:JobToken/text()"so,
        recording_token: ~x"//trc:JobConfiguration/tt:RecordingToken/text()"so,
        mode: ~x"//trc:JobConfiguration/tt:Mode/text()"so,
        priority: ~x"//trc:JobConfiguration/tt:Priority/text()"so
      )

    {:ok, parsed_result}
  end
end