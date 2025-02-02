defmodule Onvif.Search.FindRecordings do
  @moduledoc """
  FindRecordings starts a search session, looking for recordings that matches the scope defined in the request.
  Results from the search are acquired using the `Onvif.Search.GetRecordingSearchResults/2` request,
  specifying the search token returned from this request.

  The device shall continue searching until one of the following occurs:
    * The entire time range from StartPoint to EndPoint has been searched through.
    * The total number of matches has been found, defined by the MaxMatches parameter.
    * The session has been ended by a client EndSession request.
    * The session has been ended because KeepAliveTime since the last request related to this session has expired.

  The order of the results is undefined, to allow the device to return results in any order they are found.
  """

  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Search.Schemas.FindRecordings

  def soap_action, do: "http://www.onvif.org/ver10/search/wsdl/FindRecordings"

  @spec request(Onvif.Device.t(), FindRecordings.t()) :: any()
  def request(device, args) do
    Onvif.Search.request(device, args, __MODULE__)
  end

  def request_body(%FindRecordings{} = find_recordings) do
    element(:"s:Body", [FindRecordings.to_xml(find_recordings)])
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
