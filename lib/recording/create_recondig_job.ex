defmodule Onvif.Recording.CreateRecordingJob do
  import SweetXml
  import XmlBuilder
  require Logger

  def soap_action, do: "http://www.onvif.org/ver10/recording/wsdl/CreateRecordingJob"

  def request(device, args) do
    Onvif.Recording.request(device, args, __MODULE__)
  end

  def request_body(recording_token) do
    element(:"s:Body", [
      element(:"trc:CreateRecordingJob", [
        element(:"trc:JobConfiguration", [
          element(:"tt:RecordingToken", recording_token),
          element(:"tt:Mode", "Active"),
          element(:"tt:Priority", "9")
        ])
      ])
    ])
  end


  def response(xml_response_body) do
    IO.puts xml_response_body
  end
end
