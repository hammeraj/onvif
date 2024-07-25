defmodule Onvif.Media.Ver10.OSD do
  @moduledoc """
  OSD (On-Screen Display) specification.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  @required [:token, :video_source_configuration_token, :type]
  @optional []

  embedded_schema do
    field(:token, :string)
    field(:video_source_configuration_token, :string)
    field(:type, Ecto.Enum, values: [text: "Text", image: "Image", extended: "Extended"])

    embeds_one :position, Position, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:type, Ecto.Enum,
        values: [
          upper_left: "UpperLeft",
          upper_right: "UpperRight",
          lower_left: "LowerLeft",
          lower_right: "LowerRight",
          custom: "Custom"
        ]
      )

      field(:pos, :map)
    end

    embeds_one :text_string, TextString, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:is_persistent_text, :boolean)

      field(:type, Ecto.Enum,
        values: [plain: "Plain", date: "Date", time: "Time", date_and_time: "DateAndTime"]
      )

      field(:date_format, Ecto.Enum,
        values: [
          "M/d/yyyy": "M/d/yyyy",
          "MM/dd/yyyy": "MM/dd/yyyy",
          "dd/MM/yyyy": "dd/MM/yyyy",
          "yyyy/MM/dd": "yyyy/MM/dd",
          "yyyy-MM-dd": "yyyy-MM-dd",
          "dddd, MMMM dd, yyyy ": "dddd, MMMM dd, yyyy ",
          "MMMM dd, yyyy ": "MMMM dd, yyyy ",
          "dd MMMM, yyyy": "dd MMMM, yyyy"
        ]
      )

      field(:time_format, Ecto.Enum,
        values: [
          "h:mm:ss tt": "h:mm:ss tt",
          "hh:mm:ss tt": "hh:mm:ss tt",
          "H:mm:ss": "H:mm:ss",
          "HH:mm:ss": "HH:mm:ss"
        ]
      )

      field(:font_size, :integer)

      embeds_one :font_color, FontColor, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:transparent, :boolean)
        field(:color, :map)
      end

      embeds_one :background_color, BackgroundColor, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:transparent, :boolean)
        field(:color, :string)
      end

      field(:plain_text, :string)
    end

    embeds_one :image, Image, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:image_path, :string)
    end
  end

  def parse(nil), do: nil
  def parse([]), do: nil

  def parse(doc) do
    xmap(
      doc,
      token: ~x"//@token"so,
      video_source_configuration_token: ~x"./tt:VideoSourceConfigurationToken/text()"so,
      type: ~x"./tt:Type/text()"so,
      position: ~x"./tt:Position"eo |> transform_by(&parse_position/1),
      text_string: ~x"./tt:TextString"eo |> transform_by(&parse_text_string/1),
      image: ~x"./tt:Image"eo |> transform_by(&parse_image/1)
    )
  end

  def parse_position([]), do: nil
  def parse_position(nil), do: nil

  def parse_position(doc) do
    xmap(
      doc,
      type: ~x"./tt:Type/text()"so,
      pos: ~x"./tt:Pos"eo |> transform_by(&parse_pos/1)
    )
  end

  def parse_pos([]), do: nil
  def parse_pos(nil), do: nil

  def parse_pos(doc) do
    %{
      x: doc |> xpath(~x"./@x"s),
      y: doc |> xpath(~x"./@y"s)
    }
  end

  def parse_text_string([]), do: nil
  def parse_text_string(nil), do: nil

  def parse_text_string(doc) do
    xmap(
      doc,
      is_persistent_text: ~x"./tt:IsPersistentText/text()"so,
      type: ~x"./tt:Type/text()"so,
      date_format: ~x"./tt:DateFormat/text()"so,
      time_format: ~x"./tt:TimeFormat/text()"so,
      font_size: ~x"./tt:FontSize/text()"io,
      font_color: ~x"./tt:FontColor"eo |> transform_by(&parse_color/1),
      background_color: ~x"./tt:BackgroundColor"eo |> transform_by(&parse_color/1),
      plain_text: ~x"./tt:PlainText/text()"so
    )
  end

  def parse_color([]), do: nil
  def parse_color(nil), do: nil

  def parse_color(doc) do
    xmap(
      doc,
      transparent: ~x"./tt:Transparent/text()"so,
      color: ~x"./tt:Color"eo |> transform_by(&parse_inner_color/1)
    )
  end

  def parse_inner_color([]), do: nil
  def parse_inner_color(nil), do: nil

  def parse_inner_color(doc) do
    %{
      x: doc |> xpath(~x"./@X"s),
      y: doc |> xpath(~x"./@Y"s),
      z: doc |> xpath(~x"./@Z"s),
      colorspace: doc |> xpath(~x"./@Colorspace"s)
    }
  end

  def parse_image([]), do: nil
  def parse_image(nil), do: nil

  def parse_image(doc) do
    xmap(
      doc,
      image_path: ~x"./tt:ImagePath/text()"so
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(%Onvif.Media.Ver10.OSD{}) ::
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
    |> cast_embed(:position, with: &position_changeset/2)
    |> cast_embed(:text_string, with: &text_string_changeset/2)
    |> cast_embed(:image, with: &image_changeset/2)
  end

  def position_changeset(module, attrs) do
    cast(module, attrs, [:type, :pos])
  end

  def text_string_changeset(module, attrs) do
    cast(module, attrs, [
      :is_persistent_text,
      :type,
      :date_format,
      :time_format,
      :font_size,
      :plain_text
    ])
    |> cast_embed(:font_color, with: &color_changeset/2)
    |> cast_embed(:background_color, with: &color_changeset/2)
  end

  def color_changeset(module, attrs) do
    cast(module, attrs, [:transparent, :color])
  end

  def image_changeset(module, attrs) do
    cast(module, attrs, [:image_path])
  end
end
