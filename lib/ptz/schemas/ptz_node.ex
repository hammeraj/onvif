defmodule Onvif.PTZ.Schemas.PTZNode do
  @moduledoc """
  Module describing a PTZ node.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml

  alias Onvif.PTZ.Schemas.{Space1DDescription, Space2DDescription}

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:token, :string)
    field(:fixed_home_position, :boolean)
    field(:geo_move, :boolean)
    field(:name, :string)

    embeds_one :supported_ptz_spaces, SupportedPTZSpaces, primary_key: false do
      @derive Jason.Encoder
      embeds_one(:absolute_pan_tilt_position_space, Space2DDescription)
      embeds_one(:absolute_zoom_position_space, Space1DDescription)
      embeds_one(:relative_pan_tilt_translation_space, Space2DDescription)
      embeds_one(:relative_zoom_translation_space, Space1DDescription)
      embeds_one(:continuous_pan_tilt_velocity_space, Space2DDescription)
      embeds_one(:continuous_zoom_velocity_space, Space1DDescription)
      embeds_one(:pan_tilt_speed_space, Space1DDescription)
      embeds_one(:zoom_speed_space, Space1DDescription)
    end

    field(:maximum_number_of_presets, :integer)
    field(:home_supported, :boolean)
    field(:auxiliary_commands, {:array, :string})

    embeds_one :extension, Extension, primary_key: false do
      embeds_one :supported_preset_tour, SupportedPresetTour, primary_key: false do
        field(:maximum_number_of_preset_tours, :integer)
        field(:ptz_preset_tour_operation, {:array, :string})
      end
    end
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(__MODULE__.t()) :: {:error, Jason.EncodeError.t() | Exception.t()} | {:ok, binary}
  def to_json(%__MODULE__{} = schema) do
    Jason.encode(schema)
  end

  def parse(doc) do
    xmap(
      doc,
      token: ~x"./@token"s,
      fixed_home_position: ~x"./tt:FixedHomePosition/text()"s,
      geo_move: ~x"./tt:GeoMove/text()"s,
      name: ~x"./tt:Name/text()"s,
      supported_ptz_spaces:
        ~x"./tt:SupportedPTZSpaces"e |> transform_by(&parse_supported_ptz_spaces/1),
      maximum_number_of_presets: ~x"./tt:MaximumNumberOfPresets/text()"s,
      home_supported: ~x"./tt:HomeSupported/text()"s,
      auxiliary_commands: ~x"./tt:AuxiliaryCommands/text()"sl,
      extension: ~x"./tt:Extension"e |> transform_by(&parse_extension/1)
    )
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, __MODULE__.__schema__(:fields) -- [:supported_ptz_spaces, :extension])
    |> cast_embed(:supported_ptz_spaces, with: &supported_ptz_spaces_changeset/2)
    |> cast_embed(:extension, with: &extension_changeset/2)
  end

  defp parse_supported_ptz_spaces(doc) do
    xmap(
      doc,
      absolute_pan_tilt_position_space:
        ~x"./tt:AbsolutePanTiltPositionSpace"e |> transform_by(&Space2DDescription.parse/1),
      absolute_zoom_position_space:
        ~x"./tt:AbsoluteZoomPositionSpace"e |> transform_by(&Space1DDescription.parse/1),
      relative_pan_tilt_translation_space:
        ~x"./tt:RelativePanTiltTranslationSpace"e |> transform_by(&Space2DDescription.parse/1),
      relative_zoom_translation_space:
        ~x"./tt:RelativeZoomTranslationSpace"e |> transform_by(&Space1DDescription.parse/1),
      continuous_pan_tilt_velocity_space:
        ~x"./tt:ContinuousPanTiltVelocitySpace"e |> transform_by(&Space2DDescription.parse/1),
      continuous_zoom_velocity_space:
        ~x"./tt:ContinuousZoomVelocitySpace"e |> transform_by(&Space1DDescription.parse/1),
      pan_tilt_speed_space:
        ~x"./tt:PanTiltSpeedSpace"e |> transform_by(&Space1DDescription.parse/1),
      zoom_speed_space: ~x"./tt:ZoomSpeedSpace"e |> transform_by(&Space1DDescription.parse/1)
    )
  end

  defp supported_ptz_spaces_changeset(module, attrs) do
    module
    |> cast(attrs, [])
    |> cast_embed(:absolute_pan_tilt_position_space, with: &Space2DDescription.changeset/2)
    |> cast_embed(:absolute_zoom_position_space, with: &Space1DDescription.changeset/2)
    |> cast_embed(:relative_pan_tilt_translation_space, with: &Space2DDescription.changeset/2)
    |> cast_embed(:relative_zoom_translation_space, with: &Space1DDescription.changeset/2)
    |> cast_embed(:continuous_pan_tilt_velocity_space, with: &Space2DDescription.changeset/2)
    |> cast_embed(:continuous_zoom_velocity_space, with: &Space1DDescription.changeset/2)
    |> cast_embed(:pan_tilt_speed_space, with: &Space1DDescription.changeset/2)
    |> cast_embed(:zoom_speed_space, with: &Space1DDescription.changeset/2)
  end

  defp parse_extension(doc) do
    xmap(
      doc,
      supported_preset_tour:
        ~x"./tt:SupportedPresetTour"e |> transform_by(&parse_supported_preset_tour/1)
    )
  end

  defp parse_supported_preset_tour(doc) do
    xmap(
      doc,
      maximum_number_of_preset_tours: ~x"./tt:MaximumNumberOfPresetTours/text()"s,
      ptz_preset_tour_operation: ~x"./tt:PTZPresetTourOperation/text()"sl
    )
  end

  defp extension_changeset(module, attrs) do
    module
    |> cast(attrs, [])
    |> cast_embed(:supported_preset_tour, with: &supported_preset_tour_changeset/2)
  end

  defp supported_preset_tour_changeset(module, attrs) do
    cast(module, attrs, [:maximum_number_of_preset_tours, :ptz_preset_tour_operation])
  end
end
