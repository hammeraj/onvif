defmodule Onvif.Media.Ver20.GetProfiles do
  import SweetXml
  import XmlBuilder

  def soap_action, do: "http://www.onvif.org/ver20/media/wsdl/GetProfiles"

  def request(uri, auth \\ :xml_auth, args \\ []),
    do: Onvif.Media.Ver20.Media.request(uri, args, auth, __MODULE__)

  def request_body(profile_token) do
    element(:"s:Body", [
      element(:"tr2:GetProfiles", [
        element(:"tr2:Token", profile_token),
        element(:"tr2:Type", "All")
      ])
    ])
  end

  def request_body do
    element(:"s:Body", [element(:"trt:GetProfiles", [element(:"tr2:Type", "All")])])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/tr2:GetProfilesResponse/tr2:Profiles"el
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tr2", "http://www.onvif.org/ver20/media/wsdl")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
    )
    |> Enum.map(&Onvif.Media.Ver20.Profile.parse/1)
    |> Enum.map(&Onvif.Media.Ver20.Profile.to_struct/1)
  end
end
