defmodule Onvif.Media.Ver10.OSDOptions do
  @moduledoc """
  OSD (On-Screen Display) Options specification.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  @required [:type, :position_option]
  @optional []

  embedded_schema do
    field(:type, {:array, :string})
    field(:position_option, {:array, :string})

    embeds_one :maximum_number_of_osds, MaximumNumberOfOSDs,
      primary_key: false,
      on_replace: :update do
      @derive Jason.Encoder
      field(:total, :integer)
      field(:image, :integer)
      field(:plaintext, :integer)
      field(:date, :integer)
      field(:time, :integer)
      field(:date_and_time, :integer)
    end

    embeds_one :text_option, TextOption, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:type, {:array, :string})

      embeds_one :font_size_range, FontSizeRange, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:min, :integer)
        field(:max, :integer)
      end

      field(:date_format, {:array, :string})
      field(:time_format, {:array, :string})

      embeds_one :font_color, FontColor, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        embeds_one :color, Color, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:color_list, {:array, :string})

          embeds_one :color_space_range, ColorSpaceRange, primary_key: false, on_replace: :update do
            @derive Jason.Encoder
            embeds_one :x, X, primary_key: false, on_replace: :update do
              @derive Jason.Encoder
              field(:min, :integer)
              field(:max, :integer)
            end

            embeds_one :y, Y, primary_key: false, on_replace: :update do
              @derive Jason.Encoder
              field(:min, :integer)
              field(:max, :integer)
            end

            embeds_one :z, Z, primary_key: false, on_replace: :update do
              @derive Jason.Encoder
              field(:min, :integer)
              field(:max, :integer)
            end

            field(:color_space, {:array, :string})
          end
        end

        embeds_one :transparent, Transparent, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end
      end

      embeds_one :background_color, BackgroundColor, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        embeds_one :color, Color, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:color_list, {:array, :string})

          embeds_one :color_space_range, ColorSpaceRange, primary_key: false, on_replace: :update do
            @derive Jason.Encoder
            embeds_one :x, X, primary_key: false, on_replace: :update do
              @derive Jason.Encoder
              field(:min, :integer)
              field(:max, :integer)
            end

            embeds_one :y, Y, primary_key: false, on_replace: :update do
              @derive Jason.Encoder
              field(:min, :integer)
              field(:max, :integer)
            end

            embeds_one :z, Z, primary_key: false, on_replace: :update do
              @derive Jason.Encoder
              field(:min, :integer)
              field(:max, :integer)
            end

            field(:color_space, {:array, :string})
          end
        end

        embeds_one :transparent, Transparent, primary_key: false, on_replace: :update do
          @derive Jason.Encoder
          field(:min, :integer)
          field(:max, :integer)
        end
      end
    end

    embeds_one :image_option, ImageOption, primary_key: false, on_replace: :update do
      field(:formats_supported, {:array, :string})
      field(:max_size, :integer)
      field(:max_width, :integer)
      field(:max_height, :integer)
      field(:image_path, :string)
    end
  end

  def parse(nil), do: nil
  def parse([]), do: nil

  def parse(doc) do
    xmap(
      doc,
      type: ~x"./tt:Type/text()"slo,
      position_option: ~x"./tt:PositionOption/text()"slo,
      maximum_number_of_osds:
        ~x"./tt:MaximumNumberOfOSDs"eo |> transform_by(&parse_maximum_number_of_osds/1),
      text_option: ~x"./tt:TextOption"eo |> transform_by(&parse_text_option/1),
      image_option: ~x"./tt:ImageOption"eo |> transform_by(&parse_image_option/1)
    )
  end

  def parse_maximum_number_of_osds([]), do: nil
  def parse_maximum_number_of_osds(nil), do: nil

  def parse_maximum_number_of_osds(doc) do
    xmap(
      doc,
      total: ~x"//@Total"so,
      image: ~x"//@Image"so,
      plaintext: ~x"//@PlainText"so,
      date: ~x"//@Date"so,
      time: ~x"//@Time"so,
      date_and_time: ~x"//@DateAndTime"so
    )
  end

  def parse_text_option([]), do: nil
  def parse_text_option(nil), do: nil

  def parse_text_option(doc) do
    xmap(
      doc,
      type: ~x"./tt:Type/text()"slo,
      font_size_range: ~x"./tt:FontSizeRange"eo |> transform_by(&parse_int_range/1),
      date_format: ~x"./tt:DateFormat/text()"slo,
      time_format: ~x"./tt:TimeFormat/text()"slo,
      font_color: ~x"./tt:FontColor"eo |> transform_by(&parse_text_color/1),
      background_color: ~x"./tt:BackgroundColor"eo |> transform_by(&parse_text_color/1)
    )
  end

  def parse_int_range([]), do: nil
  def parse_int_range(nil), do: nil

  def parse_int_range(doc) do
    xmap(
      doc,
      min: ~x"./tt:Min/text()"so,
      max: ~x"./tt:Max/text()"so
    )
  end

  def parse_text_color([]), do: nil
  def parse_text_color(nil), do: nil

  def parse_text_color(doc) do
    xmap(
      doc,
      color: ~x"./tt:Color"eo |> transform_by(&parse_color/1),
      transparent: ~x"./tt:Transparent"eo |> transform_by(&parse_int_range/1)
    )
  end

  def parse_color([]), do: nil
  def parse_color(nil), do: nil

  def parse_color(doc) do
    xmap(
      doc,
      color_list: ~x"//@ColorList"so,
      color_space_range: ~x"./tt:ColorSpaceRange"eo |> transform_by(&parse_color_space_range/1)
    )
  end

  def parse_color_space_range([]), do: nil
  def parse_color_space_range(nil), do: nil

  def parse_color_space_range(doc) do
    xmap(
      doc,
      x: ~x"./tt:X"eo |> transform_by(&parse_int_range/1),
      y: ~x"./tt:Y"eo |> transform_by(&parse_int_range/1),
      z: ~x"./tt:Z"eo |> transform_by(&parse_int_range/1),
      color_space: ~x"//@ColorSpace"so
    )
  end

  def parse_image_option([]), do: nil
  def parse_image_option(nil), do: nil

  def parse_image_option(doc) do
    xmap(
      doc,
      formats_supported: ~x"./tt:FormatsSupported/text()"so,
      max_size: ~x"//@MaxSize"so,
      max_width: ~x"//@MaxWidth"so,
      max_height: ~x"//@MaxHeight"so,
      image_path: ~x"./tt:ImagePath/text()"so
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(%Onvif.Media.Ver10.OSDOptions{}) ::
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

  def changeset(osd_options, params \\ %{}) do
    osd_options
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:maximum_number_of_osds, with: &maximum_number_of_osds_changeset/2)
    |> cast_embed(:text_option, with: &text_option_changeset/2)
    |> cast_embed(:image_option, with: &image_option_changeset/2)
    |> validate_subset(:type, ["Image", "Text", "Extended"])
    |> validate_subset(:position_option, [
      "UpperLeft",
      "UpperRight",
      "LowerLeft",
      "LowerRight",
      "Custom"
    ])
  end

  def maximum_number_of_osds_changeset(module, attrs) do
    cast(module, attrs, [:total, :image, :plaintext, :date, :time, :date_and_time])
  end

  def text_option_changeset(module, attrs) do
    cast(module, attrs, [:type, :date_format, :time_format])
    |> cast_embed(:font_size_range, with: &int_range_changeset/2)
    |> cast_embed(:font_color, with: &text_color_changeset/2)
    |> cast_embed(:background_color, with: &text_color_changeset/2)
  end

  def int_range_changeset(module, attrs) do
    cast(module, attrs, [:min, :max])
  end

  def text_color_changeset(module, attrs) do
    cast(module, attrs, [])
    |> cast_embed(:color, with: &color_changeset/2)
    |> cast_embed(:transparent, with: &int_range_changeset/2)
  end

  def color_changeset(module, attrs) do
    cast(module, attrs, [:color_list])
    |> cast_embed(:color_space_range, with: &color_space_range_changeset/2)
  end

  def color_space_range_changeset(module, attrs) do
    cast(module, attrs, [:color_space])
    |> cast_embed(:x, with: &int_range_changeset/2)
    |> cast_embed(:y, with: &int_range_changeset/2)
    |> cast_embed(:z, with: &int_range_changeset/2)
  end

  def image_option_changeset(module, attrs) do
    cast(module, attrs, [:formats_supported, :max_size, :max_width, :max_height, :image_path])
  end
end
