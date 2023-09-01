defmodule Onvif.Media.Ver20.GetStreamUri do
  import SweetXml
  import XmlBuilder

  def soap_action, do: "http://www.onvif.org/ver20/media/wsdl/GetStreamUri"

  def request(uri, auth \\ :xml_auth, args),
    do: Onvif.Media.Ver20.Media.request(uri, args, auth, __MODULE__)

  def request_body(profile_token, protocol \\ "RTSP") do
    element(:"s:Body", [
      element(:"tr2:GetStreamUri", [
        element(:"tr2:Protocol", protocol),
        element(:"tr2:ProfileToken", profile_token)
      ])
    ])
  end

  def response(xml_response_body) do
    doc = parse(xml_response_body, namespace_conformant: true, quiet: true)

    stream_uri =
      xpath(
        doc,
        ~x"//s:Envelope/s:Body/tr2:GetStreamUriResponse/tr2:Uri/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tr2", "http://www.onvif.org/ver20/media/wsdl")
      )

    {:ok, stream_uri}
  end
end
