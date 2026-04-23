defmodule Onvif.Recording.CreateRecordingJob do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Recording.Schemas.JobConfiguration

  def soap_action, do: "http://www.onvif.org/ver10/recording/wsdl/CreateRecordingJob"

  def request(device, args) do
    Onvif.Recording.request(device, args, __MODULE__)
  end

  def request_body(%JobConfiguration{} = config) do
    element(:"s:Body", [
      element(:"trc:CreateRecordingJob", [
        element(:"trc:JobConfiguration", JobConfiguration.to_xml(config))
      ])
    ])
  end

  def response(xml_response_body) do
    parsed_result =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trc:CreateRecordingJobResponse/trc:JobToken/text()"s0
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trc", "http://www.onvif.org/ver10/recording/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )

    {:ok, parsed_result}
  end
end
