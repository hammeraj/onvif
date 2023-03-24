defmodule Onvif.Media.Ver10.GetVideoEncoderConfiguration do
  import SweetXml
  import XmlBuilder

  alias Onvif.Media.Ver10.Profile.VideoEncoderConfiguration

  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetVideoEncoderConfiguration"

  def request(uri, auth \\ :xml_auth, args), do: Onvif.Media.Ver10.Media.request(uri, args, auth, __MODULE__)

  def request_body(configuration_token) do
    element(:"s:Body", [
      element(:"tds:GetVideoEncoderConfiguration", [
        element(:"tds:ConfigurationToken", configuration_token)
      ])
    ])
  end

  @spec response(any) :: {:error, Ecto.Changeset.t()} | {:ok, VideoEncoderConfiguration.t()}
  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/trt:GetVideoEncoderConfigurationResponse/trt:Configuration"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
    )
    |> VideoEncoderConfiguration.parse()
    |> VideoEncoderConfiguration.to_struct()
  end
end
