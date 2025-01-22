defmodule Onvif.Media.Ver20.Schemas.Profile.VideoEncoderConfigurationOption do
  @moduledoc """
  Available options for video encoder configuration
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:gov_length_range, {:array, :integer})
    field(:max_anchor_frame_distance, :integer)
    field(:frame_rates_supported, {:array, :float})
    field(:profiles_supported, {:array, :string})
    field(:constant_bit_rate_supported, :boolean)
    field(:guaranteed_frame_rate_supported, :boolean)
    field(:encoding, Ecto.Enum, values: [h264: "H264", h265: "H265", jpeg: "JPEG"])

    embeds_one :quality_range, QualityRange, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:min, :float)
      field(:max, :float)
    end

    embeds_many :resolutions_available, ResolutionsAvailable,
      primary_key: false,
      on_replace: :delete do
      @derive Jason.Encoder
      field(:width, :integer)
      field(:height, :integer)
    end

    embeds_one :bitrate_range, BitrateRange, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:min, :integer)
      field(:max, :integer)
    end
  end

  def parse(doc) do
    xmap(
      doc,
      gov_length_range: ~x"./@GovLengthRange"s |> transform_by(&String.split(&1, " ")),
      max_anchor_frame_distance: ~x"./@MaxAnchorFrameDistance"I,
      frame_rates_supported: ~x"./@FrameRatesSupported"s |> transform_by(&String.split(&1, " ")),
      profiles_supported: ~x"./@ProfilesSupported"s |> transform_by(&String.split(&1, " ")),
      constant_bit_rate_supported: ~x"./@ConstantBitRateSupported"s,
      guaranteed_frame_rate_supported: ~x"./@GuaranteedFrameRateSupported"s,
      encoding: ~x"./tt:Encoding/text()"s,
      quality_range: ~x"./tt:QualityRange"e |> transform_by(&parse_float_range/1),
      resolutions_available:
        ~x"./tt:ResolutionsAvailable"el |> transform_by(&parse_resolutions_available/1),
      bitrate_range: ~x"./tt:BitrateRange"eo |> transform_by(&parse_int_range/1)
    )
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [
      :gov_length_range,
      :max_anchor_frame_distance,
      :frame_rates_supported,
      :profiles_supported,
      :constant_bit_rate_supported,
      :guaranteed_frame_rate_supported,
      :encoding
    ])
    |> cast_embed(:quality_range, with: &range_changeset/2)
    |> cast_embed(:resolutions_available, with: &resolutions_available_changeset/2)
    |> cast_embed(:bitrate_range, with: &range_changeset/2)
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  defp range_changeset(module, attrs) do
    cast(module, attrs, [:min, :max])
  end

  defp resolutions_available_changeset(module, attrs) do
    cast(module, attrs, [:width, :height])
  end

  defp parse_int_range([]) do
    nil
  end

  defp parse_int_range(nil) do
    nil
  end

  defp parse_int_range(doc) do
    xmap(
      doc,
      min: ~x"./tt:Min/text()"i,
      max: ~x"./tt:Max/text()"i
    )
  end

  defp parse_float_range(doc) do
    xmap(
      doc,
      min: ~x"./tt:Min/text()"f,
      max: ~x"./tt:Max/text()"f
    )
  end

  defp parse_resolutions_available(resolutions) do
    Enum.map(resolutions, fn resolution ->
      xmap(
        resolution,
        width: ~x"./tt:Width/text()"i,
        height: ~x"./tt:Height/text()"i
      )
    end)
  end
end
