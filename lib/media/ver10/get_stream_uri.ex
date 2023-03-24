defmodule Onvif.Media.Ver10.GetStreamUri do
  import SweetXml
  import XmlBuilder

  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetStreamUri"

  def request(uri, auth \\ :xml_auth, args), do: Onvif.Media.Ver10.Media.request(uri, args, auth, __MODULE__)

  def request_body(profile_token) do
    element(:"s:Body", [
      element(:"tds:GetStreamUri", [element(:"tds:ProfileToken", profile_token)])
    ])
  end

  def response(xml_response_body) do
    doc = parse(xml_response_body, namespace_conformant: true, quiet: true)

    stream_uri =
      xpath(
        doc,
        ~x"//s:Envelope/s:Body/trt:GetStreamUriResponse/trt:MediaUri/tt:Uri/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )

    {:ok, stream_uri}
  end
end
