defmodule Onvif.Media.Ver10.Profile.VideoEncoderConfiguration do
  @moduledoc """

  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  alias Onvif.Media.Ver10.Profile.MulticastConfiguration

  @primary_key false
  embedded_schema do
    field(:reference_token, :string)
    field(:name, :string)
    field(:use_count, :integer)
    field(:guaranteed_frame_rate, :boolean, default: false)
    field(:encoding, Ecto.Enum, values: [jpeg: "JPEG", mpeg4: "MPEG4", h264: "H264"])
    field(:quality, :float)
    field(:session_timeout, :string)

    embeds_one :resolution, Resolution, primary_key: false, on_replace: :update do
      field(:width, :integer)
      field(:height, :integer)
    end

    embeds_one :rate_control, RateControl, primary_key: false, on_replace: :update do
      field(:frame_rate_limit, :integer)
      field(:encoding_interval, :integer)
      field(:bitrate_limit, :integer)
    end

    embeds_one :mpeg4_configuration, Mpeg4Configuration, primary_key: false, on_replace: :update do
      field(:gov_length, :integer)
      field(:mpeg4_profile, Ecto.Enum, values: [simple: "SP", advanced_simple: "ASP"])
    end

    embeds_one :h264_configuration, H264Configuration, primary_key: false, on_replace: :update do
      field(:gov_length, :integer)

      field(:h264_profile, Ecto.Enum,
        values: [baseline: "Baseline", main: "Main", extended: "Extended", high: "High"]
      )
    end

    embeds_one(:multicast_configuration, MulticastConfiguration)
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      reference_token: ~x"./@token"s,
      name: ~x"./tt:Name/text()"s,
      use_count: ~x"./tt:UseCount/text()"i,
      guaranteed_frame_rate: ~x"./tt:GuaranteedFrameRate/text()"s,
      encoding: ~x"./tt:Encoding/text()"s,
      session_timeout: ~x"./tt:SessionTimeout/text()"s,
      quality: ~x"./tt:Quality/text()"f,
      resolution: ~x"./tt:Resolution"e |> transform_by(&parse_resolution/1),
      rate_control: ~x"./tt:RateControl"e |> transform_by(&parse_rate_control/1),
      mpeg4_configuration: ~x"./tt:Mpeg4"e |> transform_by(&parse_mpeg4_configuration/1),
      h264_configuration: ~x"./tt:H264"e |> transform_by(&parse_h264_configuration/1),
      multicast_configuration:
        ~x"./tt:Multicast"e |> transform_by(&MulticastConfiguration.parse/1)
    )
  end

  defp parse_resolution(doc) do
    xmap(
      doc,
      width: ~x"./tt:Width/text()"i,
      height: ~x"./tt:Height/text()"i
    )
  end

  defp parse_rate_control(doc) do
    xmap(
      doc,
      frame_rate_limit: ~x"./tt:FrameRateLimit/text()"i,
      encoding_interval: ~x"./tt:EncodingInterval/text()"i,
      bitrate_limit: ~x"./tt:BitrateLimit/text()"i
    )
  end

  defp parse_mpeg4_configuration(nil), do: nil

  defp parse_mpeg4_configuration(doc) do
    xmap(
      doc,
      gov_length: ~x"./tt:GovLength/text()"i,
      mpeg4_profile: ~x"./tt:Mpeg4Profile/text()"s
    )
  end

  defp parse_h264_configuration(nil), do: nil

  defp parse_h264_configuration(doc) do
    xmap(
      doc,
      gov_length: ~x"./tt:GovLength/text()"i,
      h264_profile: ~x"./tt:H264Profile/text()"s
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [
      :reference_token,
      :name,
      :use_count,
      :guaranteed_frame_rate,
      :encoding,
      :quality,
      :session_timeout
    ])
    |> cast_embed(:resolution, with: &resolution_changeset/2)
    |> cast_embed(:rate_control, with: &rate_control_changeset/2)
    |> cast_embed(:mpeg4_configuration, with: &mpeg4_configuration_changeset/2)
    |> cast_embed(:h264_configuration, with: &h264_configuration_changeset/2)
    |> cast_embed(:multicast_configuration)
  end

  defp resolution_changeset(module, attrs) do
    cast(module, attrs, [:width, :height])
  end

  defp rate_control_changeset(module, attrs) do
    cast(module, attrs, [:frame_rate_limit, :encoding_interval, :bitrate_limit])
  end

  defp mpeg4_configuration_changeset(module, attrs) do
    cast(module, attrs, [:gov_length, :mpeg4_profile])
  end

  defp h264_configuration_changeset(module, attrs) do
    cast(module, attrs, [:gov_length, :h264_profile])
  end
end
