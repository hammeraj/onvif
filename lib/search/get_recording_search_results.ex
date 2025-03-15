defmodule Onvif.Search.GetRecordingSearchResults do
  @moduledoc """
  GetRecordingSearchResults acquires the results from a recording search session previously initiated
  by a `Onvif.Search.FindRecordings.request/2` operation. The response shall not include results already
  returned in previous requests for the same session.

  If MaxResults is specified, the response shall not contain more than MaxResults results.
  The number of results relates to the number of recordings. For viewing individual recorded data
  for a signal track use the FindEvents method.

  GetRecordingSearchResults shall block until:
    * MaxResults results are available for the response if MaxResults is specified.
    * MinResults results are available for the response if MinResults is specified.
    * WaitTime has expired.
    * Search is completed or stopped.
  """

  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Search.Schemas.{FindRecordingResult, GetRecordingSearchResults}

  def soap_action, do: "http://www.onvif.org/ver10/search/wsdl/GetRecordingSearchResults"

  @spec request(Onvif.Device.t(), GetRecordingSearchResults.t()) :: any()
  def request(device, args) do
    Onvif.Search.request(device, args, __MODULE__)
  end

  def request_body(%GetRecordingSearchResults{} = find_recordings) do
    element(:"s:Body", [GetRecordingSearchResults.to_xml(find_recordings)])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//tse:ResultList"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tse", "http://www.onvif.org/ver10/search/wsdl")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
    )
    |> FindRecordingResult.parse()
    |> FindRecordingResult.to_struct()
  end
end
