defmodule Onvif.Media.Ver20.Profile.VideoEncoder do
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
    field(:gov_length, :integer)
    field(:profile, :string)
    field(:guaranteed_frame_rate, :boolean, default: false)

    field(:encoding, Ecto.Enum, values: [jpeg: "JPEG", mpeg4: "MPEG4", h264: "H264", h265: "H265"])

    field(:quality, :float)

    embeds_one :resolution, Resolution, primary_key: false, on_replace: :update do
      field(:width, :integer)
      field(:height, :integer)
    end

    embeds_one :rate_control, RateControl, primary_key: false, on_replace: :update do
      field(:constant_bitrate, :boolean)
      field(:frame_rate_limit, :float)
      field(:bitrate_limit, :integer)
    end

    embeds_one(:multicast_configuration, MulticastConfiguration)
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      reference_token: ~x"./@token"s,
      profile: ~x"./@Profile"s,
      gov_length: ~x"./@GovLength"io,
      name: ~x"./tt:Name/text()"s,
      use_count: ~x"./tt:UseCount/text()"i,
      guaranteed_frame_rate: ~x"./tt:GuaranteedFrameRate/text()"s,
      encoding: ~x"./tt:Encoding/text()"s,
      quality: ~x"./tt:Quality/text()"f,
      resolution: ~x"./tt:Resolution"e |> transform_by(&parse_resolution/1),
      rate_control: ~x"./tt:RateControl"e |> transform_by(&parse_rate_control/1),
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
      constant_bitrate: ~x"./@ConstantBitRate"s,
      frame_rate_limit: ~x"./tt:FrameRateLimit/text()"f,
      bitrate_limit: ~x"./tt:BitrateLimit/text()"i
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
      :profile,
      :gov_length,
      :guaranteed_frame_rate,
      :encoding,
      :quality
    ])
    |> cast_embed(:resolution, with: &resolution_changeset/2)
    |> cast_embed(:rate_control, with: &rate_control_changeset/2)
    |> cast_embed(:multicast_configuration)
  end

  defp resolution_changeset(module, attrs) do
    cast(module, attrs, [:width, :height])
  end

  defp rate_control_changeset(module, attrs) do
    cast(module, attrs, [:frame_rate_limit, :constant_bitrate, :bitrate_limit])
  end
end
