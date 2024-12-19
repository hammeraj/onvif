defmodule Onvif.Search.GetRecordingSummary do
  import SweetXml
  import XmlBuilder
  require Logger

  def soap_action, do: "http://www.onvif.org/ver10/search/wsdl/GetRecordingSummary"

  def request(device) do
    Onvif.Search.request(device, __MODULE__)
  end

  def request_body() do
    element(:"s:Body", [
      element(:"tse:GetRecordingSummary")
    ])
  end

  def response(xml_response_body) do
    doc = parse(xml_response_body, namespace_conformant: true, quiet: true)

    parsed_result =
      xpath(
        doc,
        ~x"//s:Envelope/s:Body/tse:GetRecordingSummaryResponse/tse:Summary"
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tse", "http://www.onvif.org/ver10/search/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
        data_from: ~x"//tt:DataFrom/text()"so,
        data_until: ~x"//tt:DataUntil/text()"so,
        number_recordings: ~x"//tt:NumberRecordings/text()"so
      )

    {:ok, parsed_result}
  end
end
