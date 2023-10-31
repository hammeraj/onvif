defmodule Onvif.Media.Ver10.SetAudioEncoderConfiguration do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Media.Ver10.Profile.AudioEncoderConfiguration

  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/SetAudioEncoderConfiguration"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  @spec request_body(%AudioEncoderConfiguration{}) :: tuple()
  def request_body(%AudioEncoderConfiguration{} = audio_encoder_config) do
    element(:"s:Body", [
      element(:"trt:SetAudioEncoderConfiguration", [
        element(:"trt:Configuration", %{"token" => audio_encoder_config.reference_token}, [
          element(:"tt:Name", audio_encoder_config.name),
          element(:"tt:UseCount", audio_encoder_config.use_count),
          element(
            :"tt:Encoding",
            Keyword.fetch!(
              Ecto.Enum.mappings(audio_encoder_config.__struct__, :encoding),
              audio_encoder_config.encoding
            )
          ),
          element(:"tt:Bitrate", audio_encoder_config.bitrate),
          element(:"tt:SampleRate", audio_encoder_config.sample_rate),
          element(:"tt:Multicast", [
            element(:"tt:Address", [
              element(
                :"tt:Type",
                Keyword.fetch!(
                  Ecto.Enum.mappings(
                    audio_encoder_config.multicast_configuration.ip_address.__struct__,
                    :type
                  ),
                  audio_encoder_config.multicast_configuration.ip_address.type
                )
              ),
              ip_address_element(audio_encoder_config.multicast_configuration)
            ]),
            element(:"tt:Port", audio_encoder_config.multicast_configuration.port),
            element(:"tt:TTL", audio_encoder_config.multicast_configuration.ttl),
            element(:"tt:AutoStart", audio_encoder_config.multicast_configuration.auto_start)
          ]),
          element(:"tt:SessionTimeout", audio_encoder_config.session_timeout)
        ]),
        element(:"trt:ForcePersistence", true)
      ])
    ])
  end

  defp ip_address_element(%{ip_address: %{type: :ipv4}} = multicast_configuration),
    do: element(:"tt:IPv4Address", multicast_configuration.ip_address.ipv4_address)

  defp ip_address_element(multicast_configuration),
    do: element(:"tt:IPv6Address", multicast_configuration.ip_address.ipv6_address)

  @spec response(String.t()) :: {:ok, String.t()}
  def response(xml_response_body) do
    res =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trt:SetAudioEncoderConfigurationResponse/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )

    {:ok, res}
  end
end
