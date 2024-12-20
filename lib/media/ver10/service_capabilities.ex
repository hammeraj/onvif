defmodule Onvif.Media.Ver10.ServiceCapabilities do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  @required []
  @optional [
    :snapshot_uri,
    :rotation,
    :video_source_mode,
    :osd,
    :temporary_osd_text,
    :exi_compression
  ]
  embedded_schema do
    field(:snapshot_uri, :boolean, default: false)
    field(:rotation, :boolean, default: false)
    field(:video_source_mode, :boolean, default: false)
    field(:osd, :boolean, default: false)
    field(:temporary_osd_text, :boolean, default: false)
    field(:exi_compression, :boolean, default: false)

    embeds_one :profile_capabilities, ProfileCapabilities, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:maximum_number_of_profiles, :integer)
    end

    embeds_one :streaming_capabilities, StreamingCapabilities,
      primary_key: false,
      on_replace: :update do
      @derive Jason.Encoder
      field(:rtsp_multicast, :boolean, default: false)
      field(:rtp_tcp, :boolean, default: false)
      field(:rtp_rtsp_tcp, :boolean, default: false)
      field(:non_aggregated_control, :boolean, default: false)
      field(:no_rtsp_streaming, :boolean, default: false)
    end
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(%Onvif.Media.Ver10.Profile.VideoEncoderConfiguration{}) ::
          {:error,
           %{
             :__exception__ => any,
             :__struct__ => Jason.EncodeError | Protocol.UndefinedError,
             optional(atom) => any
           }}
          | {:ok, binary}
  def to_json(%__MODULE__{} = schema) do
    Jason.encode(schema)
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:profile_capabilities, with: &profile_capabilities_changeset/2)
    |> cast_embed(:streaming_capabilities,
      with: &streaming_capabilities_changeset/2
    )
  end

  def parse(nil), do: nil
  def parse([]), do: nil

  def parse(doc) do
    xmap(
      doc,
      snapshot_uri: ~x"./@SnapshotUri"so,
      rotation: ~x"./@Rotation"so,
      video_source_mode: ~x"./@VideoSourceMode"so,
      osd: ~x"./@OSD"so,
      temporary_osd_text: ~x"./@TemporaryOSDText"so,
      exi_compression: ~x"./@EXICompression"so,
      profile_capabilities:
        ~x"./trt:ProfileCapabilities"eo |> transform_by(&parse_profile_capabilities/1),
      streaming_capabilities:
        ~x"./trt:StreamingCapabilities"eo |> transform_by(&parse_streaming_capabilities/1)
    )
  end

  defp profile_capabilities_changeset(module, attrs) do
    cast(module, attrs, [:maximum_number_of_profiles])
  end

  defp streaming_capabilities_changeset(module, attrs) do
    cast(module, attrs, [
      :rtsp_multicast,
      :rtp_tcp,
      :rtp_rtsp_tcp,
      :non_aggregated_control,
      :no_rtsp_streaming
    ])
  end

  defp parse_profile_capabilities([]), do: nil
  defp parse_profile_capabilities(nil), do: nil

  defp parse_profile_capabilities(doc) do
    xmap(
      doc,
      maximum_number_of_profiles: ~x"./@MaximumNumberOfProfiles"i
    )
  end

  defp parse_streaming_capabilities([]), do: nil
  defp parse_streaming_capabilities(nil), do: nil

  defp parse_streaming_capabilities(doc) do
    xmap(
      doc,
      rtsp_multicast: ~x"./@RTPMulticast "so,
      rtp_tcp: ~x"./@RTP_TCP"so,
      rtp_rtsp_tcp: ~x"./@RTP_RTSP_TCP"so,
      non_aggregated_control: ~x"./@NonAggregateControl"so,
      no_rtsp_streaming: ~x"./@NoRTSPStreaming"so
    )
  end
end
