defmodule Onvif.Search.FindEvents do
  import SweetXml
  import XmlBuilder
  require Logger

  def soap_action, do: "http://www.onvif.org/ver10/search/wsdl/FindEvents"

  def request(device, args) do
    Onvif.Search.request(device, args, __MODULE__)
  end

  def request_body([included_recordings, start_point, end_point, search_filter, keep_alive_time]) do
    element(:"s:Body", [
      element(:"tse:FindEvents", [
        element(:"tse:StartPoint", start_point),
        element(:"tse:EndPoint", end_point),
        element(:"tse:scope", [
          Enum.map(included_recordings, fn ir -> element(:"tt:IncludedRecordings", [ir]) end)
        ]),
        element(:"tt:SearchFilter", [search_filter]),
        element(:"tse:IncludeStartState", false),
        element(:"tse:KeepAliveTime", keep_alive_time)
      ])
    ])
  end

  def response(xml_response_body) do
    parsed_result =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//tse:SearchToken/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tse", "http://www.onvif.org/ver10/search/wsdl")
      )

    {:ok, parsed_result}
  end
end
