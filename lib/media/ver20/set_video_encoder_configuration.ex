defmodule Onvif.Media.Ver20.SetVideoEncoderConfiguration do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Media.Ver20.Schemas.Profile.VideoEncoder

  def soap_action, do: "http://www.onvif.org/ver20/media/wsdl/SetVideoEncoderConfiguration"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args),
    do: Onvif.Media.Ver20.Media.request(device, args, __MODULE__)

  def request_body(%VideoEncoder{} = video_encoder_config) do
    element(:"s:Body", [
      element(:"tr2:SetVideoEncoderConfiguration", [
        element(
          :"tr2:Configuration",
          %{
            "token" => video_encoder_config.reference_token,
            "Profile" => video_encoder_config.profile,
            "GovLength" => video_encoder_config.gov_length
          },
          [
            element(:"tt:Name", video_encoder_config.name),
            element(:"tt:UseCount", video_encoder_config.use_count),
            element(
              :"tt:Encoding",
              Keyword.fetch!(
                Ecto.Enum.mappings(video_encoder_config.__struct__, :encoding),
                video_encoder_config.encoding
              )
            ),
            element(:"tt:Quality", trunc(video_encoder_config.quality)),
            element(
              :"tt:Resolution",
              [
                element(:"tt:Width", video_encoder_config.resolution.width),
                element(:"tt:Height", video_encoder_config.resolution.height)
              ]
            ),
            element(
              :"tt:RateControl",
              %{"ConstantBitRate" => video_encoder_config.rate_control.constant_bitrate},
              [
                element(:"tt:FrameRateLimit", video_encoder_config.rate_control.frame_rate_limit),
                element(:"tt:BitrateLimit", video_encoder_config.rate_control.bitrate_limit)
              ]
            ),
            element(:"tt:Multicast", [
              element(:"tt:Address", [
                element(
                  :"tt:Type",
                  Keyword.fetch!(
                    Ecto.Enum.mappings(
                      video_encoder_config.multicast_configuration.ip_address.__struct__,
                      :type
                    ),
                    video_encoder_config.multicast_configuration.ip_address.type
                  )
                ),
                ip_address_element(video_encoder_config.multicast_configuration)
              ]),
              element(:"tt:Port", video_encoder_config.multicast_configuration.port),
              element(:"tt:TTL", video_encoder_config.multicast_configuration.ttl),
              element(:"tt:AutoStart", video_encoder_config.multicast_configuration.auto_start)
            ])
          ]
        )
      ])
    ])
  end

  defp ip_address_element(%{ip_address: %{type: :ipv4}} = multicast_configuration),
    do: element(:"tt:IPv4Address", multicast_configuration.ip_address.ipv4_address)

  defp ip_address_element(multicast_configuration),
    do: element(:"tt:IPv6Address", multicast_configuration.ip_address.ipv6_address)

  def response(xml_response_body) do
    res =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tr2:SetVideoEncoderConfigurationResponse/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tr2", "http://www.onvif.org/ver20/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver20/schema")
      )

    {:ok, res}
  end
end
