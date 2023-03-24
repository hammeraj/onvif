defmodule Onvif.Media.Ver10.SetVideoEncoderConfiguration do
  alias Onvif.Media.Ver10.Profile.VideoEncoderConfiguration
  import SweetXml
  import XmlBuilder

  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/SetVideoEncoderConfiguration"

  def request(uri, auth \\ :xml_auth, args), do: Onvif.Media.Ver10.Media.request(uri, args, auth, __MODULE__)

  def request_body(%VideoEncoderConfiguration{} = video_encoder_config) do
    element(:"s:Body", [
      element(:"trt:SetVideoEncoderConfiguration", [
        element(:"trt:Configuration", %{"token" => video_encoder_config.reference_token}, [
          element(
            :"tt:Encoding",
            Keyword.fetch!(
              Ecto.Enum.mappings(video_encoder_config.__struct__, :encoding),
              video_encoder_config.encoding
            )
          ),
          element(:"tt:Quality", video_encoder_config.quality),
          element(
            :"tt:Resolution",
            [
              element(:"tt:Width", video_encoder_config.resolution.width),
              element(:"tt:Height", video_encoder_config.resolution.height)
            ]
          ),
          element(:"tt:RateControl", [
            element(:"tt:FrameRateLimit", video_encoder_config.rate_control.frame_rate_limit),
            element(:"tt:EncodingInterval", video_encoder_config.rate_control.encoding_interval),
            element(:"tt:BitrateLimit", video_encoder_config.rate_control.bitrate_limit)
          ]),
          multicast_element(video_encoder_config.multicast_configuration)
        ])
      ])
    ])
  end

  defp multicast_element(%{ip_address: %{type: :ipv4}} = multicast_configuration) do
    element(:"tt:Multicast", [
      element(:"tt:Address", [
        element(
          :"tt:Type",
          Keyword.fetch!(
            Ecto.Enum.mappings(multicast_configuration.ip_address.__struct__, :type),
            multicast_configuration.ip_address.type
          )
        ),
        element(:"tt:IPv4Address", multicast_configuration.ip_address.ipv4_address)
      ]),
      element(:"tt:Port", multicast_configuration.port),
      element(:"tt:TTL", multicast_configuration.ttl),
      element(:"tt:AutoStart", multicast_configuration.auto_start)
    ])
  end

  defp multicast_element(%{ip_address: %{type: :ipv6}} = multicast_configuration) do
    element(:"tt:Multicast", [
      element(:"tt:Address", [
        element(
          :"tt:Type",
          Keyword.fetch!(
            Ecto.Enum.mappings(multicast_configuration.ip_address.__struct__, :type),
            multicast_configuration.ip_address.type
          )
        ),
        element(:"tt:IPv6Address", multicast_configuration.ip_address.ipv6_address)
      ]),
      element(:"tt:Port", multicast_configuration.port),
      element(:"tt:TTL", multicast_configuration.ttl),
      element(:"tt:AutoStart", multicast_configuration.auto_start)
    ])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/trt:SetVideoEncoderConfigurationResponse/text()"s
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
    )
  end
end
