defmodule Onvif.Media.Ver10.Profile.VideoEncoderConfigurationOption do
  @moduledoc """
  Optional configuration of the Video encoder.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:guranteed_frame_rate_supported, :boolean)

    embeds_one :quality_range, QualityRange, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:min, :integer)
      field(:max, :integer)
    end

    embeds_one :jpeg, JpegOptions, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      embeds_many :resolutions_available, ResolutionsAvailable,
        primary_key: false,
        on_replace: :delete do
        @derive Jason.Encoder
        field(:width, :integer)
        field(:height, :integer)
      end

      embeds_one :frame_rate_range, FrameRateRange, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:min, :integer)
        field(:max, :integer)
      end

      embeds_one :encoding_interval_range, EncodingIntervalRange,
        primary_key: false,
        on_replace: :update do
        @derive Jason.Encoder
        field(:min, :integer)
        field(:max, :integer)
      end
    end

    embeds_one :mpeg4, Mpeg4Options, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:mpeg4_profiles_supported, {:array, :string})

      embeds_many :resolutions_available, ResolutionsAvailable,
        primary_key: false,
        on_replace: :delete do
        @derive Jason.Encoder
        field(:width, :integer)
        field(:height, :integer)
      end

      embeds_one :gov_length_range, GovLengthRange, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:min, :integer)
        field(:max, :integer)
      end

      embeds_one :frame_rate_range, FrameRateRange, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:min, :integer)
        field(:max, :integer)
      end

      embeds_one :encoding_interval_range, EncodingIntervalRange,
        primary_key: false,
        on_replace: :update do
        @derive Jason.Encoder
        field(:min, :integer)
        field(:max, :integer)
      end
    end

    embeds_one :h264, H264Options, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:h264_profiles_supported, {:array, :string})

      embeds_many :resolutions_available, ResolutionsAvailable,
        primary_key: false,
        on_replace: :delete do
        @derive Jason.Encoder
        field(:width, :integer)
        field(:height, :integer)
      end

      embeds_one :gov_length_range, GovLengthRange, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:min, :integer)
        field(:max, :integer)
      end

      embeds_one :frame_rate_range, FrameRateRange, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:min, :integer)
        field(:max, :integer)
      end

      embeds_one :encoding_interval_range, EncodingIntervalRange,
        primary_key: false,
        on_replace: :update do
        @derive Jason.Encoder
        field(:min, :integer)
        field(:max, :integer)
      end
    end

    embeds_one :extension, Extension, primary_key: false, on_replace: :update do
      embeds_one :jpeg, JpegOptions, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        embeds_many :resolutions_available, ResolutionsAvailable,
          primary_key: false,
          on_replace: :delete do
          @derive Jason.Encoder
          field(:width, :integer)
          field(:height, :integer)
        end

        embeds_one :frame_rate_range, FrameRateRange, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end

        embeds_one :encoding_interval_range, EncodingIntervalRange,
          primary_key: false,
          on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end

        embeds_one :bitrate_range, BitrateRange, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end
      end

      embeds_one :mpeg4, Mpeg4Options, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:mpeg4_profiles_supported, {:array, :string})

        embeds_many :resolutions_available, ResolutionsAvailable,
          primary_key: false,
          on_replace: :delete do
          @derive Jason.Encoder
          field(:width, :integer)
          field(:height, :integer)
        end

        embeds_one :gov_length_range, GovLengthRange, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end

        embeds_one :frame_rate_range, FrameRateRange, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end

        embeds_one :encoding_interval_range, EncodingIntervalRange,
          primary_key: false,
          on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end

        embeds_one :bitrate_range, BitrateRange, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end
      end

      embeds_one :h264, H264Options, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:h264_profiles_supported, {:array, :string})

        embeds_many :resolutions_available, ResolutionsAvailable1,
          primary_key: false,
          on_replace: :delete do
          @derive Jason.Encoder
          field(:width, :integer)
          field(:height, :integer)
        end

        embeds_one :gov_length_range, GovLengthRange, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end

        embeds_one :frame_rate_range, FrameRateRange, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end

        embeds_one :encoding_interval_range, EncodingIntervalRange,
          primary_key: false,
          on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end

        embeds_one :bitrate_range, BitrateRange, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end
      end
    end
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [:guranteed_frame_rate_supported])
    |> cast_embed(:quality_range, with: &int_range_changeset/2)
    |> cast_embed(:jpeg, with: &jpeg_changeset/2)
    |> cast_embed(:mpeg4, with: &mpeg4_changeset/2)
    |> cast_embed(:h264, with: &h264_changeset/2)
    |> cast_embed(:extension, with: &extension_changeset/2)
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(%Onvif.Media.Ver10.Profile.VideoEncoderConfigurationOption{}) ::
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

  def parse(doc) do
    xmap(
      doc,
      guranteed_frame_rate_supported: ~x"./tt:GuaranteedFrameRateSupported"s,
      quality_range: ~x"./tt:QualityRange"e |> transform_by(&parse_int_range/1),
      jpeg: ~x"./tt:JPEG"eo |> transform_by(&parse_jpeg/1),
      mpeg4: ~x"./tt:MPEG4"eo |> transform_by(&parse_mpeg4/1),
      h264: ~x"./tt:H264"eo |> transform_by(&parse_h264/1),
      extension: ~x"./tt:Extension"eo |> transform_by(&parse_extension/1)
    )
  end

  defp jpeg_changeset(module, attrs) do
    module
    |> cast(attrs, [])
    |> cast_embed(:resolutions_available, with: &resolutions_available_changeset/2)
    |> cast_embed(:frame_rate_range, with: &int_range_changeset/2)
    |> cast_embed(:encoding_interval_range, with: &int_range_changeset/2)
  end

  defp mpeg4_changeset(module, attrs) do
    module
    |> cast(attrs, [:mpeg4_profiles_supported])
    |> cast_embed(:resolutions_available, with: &resolutions_available_changeset/2)
    |> cast_embed(:gov_length_range, with: &int_range_changeset/2)
    |> cast_embed(:frame_rate_range, with: &int_range_changeset/2)
    |> cast_embed(:encoding_interval_range, with: &int_range_changeset/2)
  end

  defp h264_changeset(module, attrs) do
    module
    |> cast(attrs, [:h264_profiles_supported])
    |> cast_embed(:resolutions_available, with: &resolutions_available_changeset/2)
    |> cast_embed(:gov_length_range, with: &int_range_changeset/2)
    |> cast_embed(:frame_rate_range, with: &int_range_changeset/2)
    |> cast_embed(:encoding_interval_range, with: &int_range_changeset/2)
  end

  defp extension_changeset(module, attrs) do
    module
    |> cast(attrs, [])
    |> cast_embed(:jpeg, with: &jpeg_extension_changeset/2)
    |> cast_embed(:mpeg4, with: &mpeg4_extension_changeset/2)
    |> cast_embed(:h264, with: &h264_extension_changeset/2)
  end

  defp jpeg_extension_changeset(module, attrs) do
    module
    |> jpeg_changeset(attrs)
    |> cast_embed(:bitrate_range, with: &int_range_changeset/2)
  end

  defp mpeg4_extension_changeset(module, attrs) do
    module
    |> mpeg4_changeset(attrs)
    |> cast_embed(:bitrate_range, with: &int_range_changeset/2)
  end

  defp h264_extension_changeset(module, attrs) do
    module
    |> h264_changeset(attrs)
    |> cast_embed(:bitrate_range, with: &int_range_changeset/2)
  end

  defp resolutions_available_changeset(module, attrs) do
    cast(module, attrs, [:width, :height])
  end

  defp int_range_changeset(module, attrs) do
    cast(module, attrs, [:min, :max])
  end

  defp parse_jpeg(nil) do
    nil
  end

  defp parse_jpeg(doc) do
    xmap(
      doc,
      resolutions_available:
        ~x"./tt:ResolutionsAvailable"el |> transform_by(&parse_resolutions_available/1),
      frame_rate_range: ~x"./tt:FrameRateRange"e |> transform_by(&parse_int_range/1),
      encoding_interval_range:
        ~x"./tt:EncodingIntervalRange"e |> transform_by(&parse_int_range/1),
      bitrate_range: ~x"./tt:BitrateRange"eo |> transform_by(&parse_int_range/1)
    )
  end

  defp parse_mpeg4(nil) do
    nil
  end

  defp parse_mpeg4(doc) do
    xmap(
      doc,
      resolutions_available:
        ~x"./tt:ResolutionsAvailable"el |> transform_by(&parse_resolutions_available/1),
      gov_length_range: ~x"./tt:GovLengthRange"e |> transform_by(&parse_int_range/1),
      frame_rate_range: ~x"./tt:FrameRateRange"e |> transform_by(&parse_int_range/1),
      encoding_interval_range:
        ~x"./tt:EncodingIntervalRange"e |> transform_by(&parse_int_range/1),
      h264_profiles_supported: ~x"./tt:MPEG4ProfilesSupported/text()"sl,
      bitrate_range: ~x"./tt:BitrateRange"eo |> transform_by(&parse_int_range/1)
    )
  end

  defp parse_h264(nil) do
    nil
  end

  defp parse_h264(doc) do
    xmap(
      doc,
      resolutions_available:
        ~x"./tt:ResolutionsAvailable"el |> transform_by(&parse_resolutions_available/1),
      gov_length_range: ~x"./tt:GovLengthRange"e |> transform_by(&parse_int_range/1),
      frame_rate_range: ~x"./tt:FrameRateRange"e |> transform_by(&parse_int_range/1),
      encoding_interval_range:
        ~x"./tt:EncodingIntervalRange"e |> transform_by(&parse_int_range/1),
      h264_profiles_supported: ~x"./tt:H264ProfilesSupported/text()"sl,
      bitrate_range: ~x"./tt:BitrateRange"eo |> transform_by(&parse_int_range/1)
    )
  end

  defp parse_extension(nil) do
    nil
  end

  defp parse_extension(doc) do
    xmap(
      doc,
      jpeg: ~x"./tt:JPEG"eo |> transform_by(&parse_jpeg/1),
      mpeg4: ~x"./tt:MPEG4"eo |> transform_by(&parse_mpeg4/1),
      h264: ~x"./tt:H264"eo |> transform_by(&parse_h264/1)
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
end
