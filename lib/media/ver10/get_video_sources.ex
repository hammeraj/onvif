defmodule Onvif.Media.Ver10.GetVideoSources do
  import SweetXml
  import XmlBuilder

  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetVideoSources"

  def request(uri, auth \\ :xml_auth),
    do: Onvif.Media.Ver10.Media.request(uri, [], auth, __MODULE__)

  @spec request_body() :: list | {any, any, any}
  def request_body() do
    element(:"s:Body", [
      element(:"tds:GetVideoSources")
    ])
  end

  def response(xml_response_body) do
    xml_response_body
    # doc = parse(xml_response_body, namespace_conformant: true, quiet: true)

    # stream_uri =
    #   xpath(
    #     doc,
    #     ~x"//s:Envelope/s:Body/trt:GetVideoSourceResponse/trt:MediaUri/tt:Uri/text()"s
    #     |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
    #     |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
    #     |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
    #   )

    # {:ok, stream_uri}
  end
end
