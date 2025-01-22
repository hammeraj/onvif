defmodule Onvif.Media.Ver10.GetAudioEncoderConfiguration do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Media.Ver10.Schemas.Profile.AudioEncoderConfiguration

  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetAudioEncoderConfiguration"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  def request_body(configuration_token) do
    element(:"s:Body", [
      element(:"trt:GetAudioEncoderConfiguration", [
        element(:"trt:ConfigurationToken", configuration_token)
      ])
    ])
  end

  @spec response(any) :: {:error, Ecto.Changeset.t()} | {:ok, struct()}
  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/trt:GetAudioEncoderConfigurationResponse/trt:Configuration"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
    )
    |> AudioEncoderConfiguration.parse()
    |> AudioEncoderConfiguration.to_struct()
  end
end
