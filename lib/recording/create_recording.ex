defmodule Onvif.Recording.CreateRecording do
  import SweetXml
  import XmlBuilder
  require Logger

  def soap_action, do: "http://www.onvif.org/ver10/recording/wsdl/CreateRecording"

  def request(device, args) do
    Onvif.Recording.request(device, args, __MODULE__)
  end

  def request_body(config: %Onvif.Recording.Recording.Configuration{} = config) do
    element(:"s:Body", [
      element(:"trc:CreateRecording", [
        element(:"trc:RecordingConfiguration", [
          element(:"tt:Source", [
            gen_source_id(config.source.source_id),
            gen_name(config.source.name),
            gen_location(config.source.location),
            gen_description(config.source.description),
            gen_address(config.source.address)
          ]),
          gen_content(config.content),
          gen_maximum_retention_time(config.maximum_retention_time)
        ])
      ])
    ])
  end

  def gen_source_id(nil), do: []
  def gen_source_id(""), do: []
  def gen_source_id(source_id), do: element(:"tt:SourceId", source_id)

  def gen_name(nil), do: []
  def gen_name(""), do: []
  def gen_name(name), do: element(:"tt:Name", name)

  def gen_location(nil), do: []
  def gen_location(""), do: []
  def gen_location(location), do: element(:"tt:Location", location)

  def gen_description(nil), do: []
  def gen_description(""), do: []
  def gen_description(description), do: element(:"tt:Description", description)

  def gen_address(nil), do: []
  def gen_address(""), do: []
  def gen_address(address), do: element(:"tt:Address", address)

  def gen_content(nil), do: []
  def gen_content(""), do: []
  def gen_content(content), do: element(:"tt:Content", content)

  def gen_maximum_retention_time(nil), do: []
  def gen_maximum_retention_time(""), do: []
  def gen_maximum_retention_time(maximum_retention_time), do: element(:"tt:MaximumRetentionTime", maximum_retention_time)


  def response(xml_response_body) do
    recording_token =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trc:CreateRecordingResponse/trc:RecordingToken/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trc", "http://www.onvif.org/ver10/recording/wsdl")
      )

    {:ok, recording_token}
  end
end
