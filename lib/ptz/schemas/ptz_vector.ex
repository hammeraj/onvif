defmodule Onvif.PTZ.Schemas.PTZVector do
  @moduledoc """
  PTZ speed/vector schema
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml
  import XmlBuilder

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    embeds_one :pan_tilt, PanTilt, primary_key: false do
      @derive Jason.Encoder
      field(:x, :float)
      field(:y, :float)
      field(:space, :string)
    end

    field(:zoom, :float)
  end

  def changeset(ptz_speed, attrs) do
    ptz_speed
    |> cast(attrs, [:zoom])
    |> cast_embed(:pan_tilt, with: &pan_tilt_changeset/2)
  end

  def to_xml(nil), do: []

  def to_xml(struct) do
    []
    |> xml_zoom(struct)
    |> xml_pan_tilt(struct)
  end

  def parse(doc) do
    xmap(
      doc,
      pan_tilt: ~x"./tt:PanTilt" |> transform_by(&pase_pan_tilt/1),
      zoom: ~x"./tt:Zoom/@x"s
    )
  end

  @spec with_zoom(t(), float()) :: t()
  def with_zoom(struct, x) do
    %__MODULE__{struct | zoom: x}
  end

  @spec with_pan_tilt(t(), float(), float()) :: t()
  def with_pan_tilt(struct, x, y) do
    %__MODULE__{struct | pan_tilt: %__MODULE__.PanTilt{x: x, y: y}}
  end

  defp pase_pan_tilt(doc) do
    xmap(
      doc,
      x: ~x"./@x"s,
      y: ~x"./@y"s,
      space: ~x"./@space"s
    )
  end

  defp pan_tilt_changeset(pan_tilt, attrs) do
    pan_tilt
    |> cast(attrs, [:x, :y, :space])
    |> validate_required([:x, :y])
  end

  defp xml_zoom(xml, %__MODULE__{zoom: nil}), do: xml

  defp xml_zoom(xml, %__MODULE__{zoom: zoom}),
    do: [element("tptz:Zoom", [x: zoom], []) | xml]

  defp xml_pan_tilt(xml, %__MODULE__{pan_tilt: nil}), do: xml

  defp xml_pan_tilt(xml, %__MODULE__{pan_tilt: pan_tilt}) do
    [element("tptz:PanTilt", [x: pan_tilt.x, y: pan_tilt.y], []) | xml]
  end
end
