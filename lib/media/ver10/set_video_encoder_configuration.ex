defmodule Onvif.Media.Ver10.SetVideoEncoderConfiguration do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Media.Ver10.Profile.VideoEncoderConfiguration

  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/SetVideoEncoderConfiguration"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  def request_body(%VideoEncoderConfiguration{} = video_encoder_config) do
    element(:"s:Body", [
      element(:"trt:SetVideoEncoderConfiguration", [
        element(:"trt:Configuration", %{"token" => video_encoder_config.reference_token}, [
          element(:"tt:Name", video_encoder_config.name),
          element(:"tt:UseCount", video_encoder_config.use_count),
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
          List.flatten(encoder_config_element(video_encoder_config)),
          multicast_element(video_encoder_config.multicast_configuration),
          element(:"tt:SessionTimeout", video_encoder_config.session_timeout)
        ]),
        element(:"trt:ForcePersistence", true)
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
    res =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trt:SetVideoEncoderConfigurationResponse/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )

    {:ok, res}
  end

  defp encoder_config_element(%VideoEncoderConfiguration{
         h264_configuration: nil,
         mpeg4_configuration: nil
       }) do
    [{}]
  end

  defp encoder_config_element(%VideoEncoderConfiguration{
         h264_configuration: h264_configuration,
         mpeg4_configuration: nil
       }) do
    [
      element(:"tt:H264", [
        element(:"tt:GovLength", h264_configuration.gov_length),
        element(
          :"tt:H264Profile",
          Keyword.fetch!(
            Ecto.Enum.mappings(h264_configuration.__struct__, :h264_profile),
            h264_configuration.h264_profile
          )
        )
      ])
    ]
  end

  defp encoder_config_element(%VideoEncoderConfiguration{
         h264_configuration: nil,
         mpeg4_configuration: mpeg4_configuration
       }) do
    [
      element(:"tt:MPEG4", [
        element(:"tt:GovLength", mpeg4_configuration.gov_length),
        element(
          :"tt:Mpeg4Profile",
          Keyword.fetch!(
            Ecto.Enum.mappings(mpeg4_configuration.__struct__, :mpeg4_profile),
            mpeg4_configuration.mpeg4_profile
          )
        )
      ])
    ]
  end
end
