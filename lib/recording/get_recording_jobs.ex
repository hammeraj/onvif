defmodule Onvif.Recording.GetRecordingJobs do
  import SweetXml
  import XmlBuilder
  require Logger

  def soap_action, do: "http://www.onvif.org/ver10/recording/wsdl/GetRecordingJobs"

  def request(device) do
    Onvif.Recording.request(device, __MODULE__)
  end

  def request_body() do
    element(:"s:Body", [
      element(:"trc:GetRecordingJobs")
    ])
  end

  def response(xml_response_body) do
    IO.puts(xml_response_body)
  end
end
