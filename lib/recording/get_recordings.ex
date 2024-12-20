defmodule Onvif.Recording.GetRecordings do
  import SweetXml
  import XmlBuilder
  require Logger

  alias Onvif.Recording.Recording

  def soap_action, do: "http://www.onvif.org/ver10/recording/wsdl/GetRecordings"

  def request(device) do
    Onvif.Recording.request(device, __MODULE__)
  end

  def request_body() do
    element(:"s:Body", [
      element(:"trc:GetRecordings")
    ])
  end

  def response(xml_response_body) do
    response =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trc:GetRecordingsResponse/trc:RecordingItem"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trc", "http://www.onvif.org/ver10/recording/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Enum.map(&Recording.parse/1)
      |> Enum.reduce([], fn raw_recording, acc ->
        case Recording.to_struct(raw_recording) do
          {:ok, recording} ->
            [recording | acc]

          {:error, changeset} ->
            Logger.error("Discarding invalid recording: #{inspect(changeset)}")
            acc
        end
      end)

    {:ok, response}
  end
end
