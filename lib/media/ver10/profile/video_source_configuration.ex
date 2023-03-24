defmodule Onvif.Media.Ver10.Profile.VideoSourceConfiguration do
  @moduledoc """
  Optional configuration of the Video input.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  embedded_schema do
    field(:reference_token, :string)
    field(:name, :string)
    field(:use_count, :integer)
    field(:view_mode, :string)
    field(:source_token, :string)

    embeds_one :bounds, Bounds, primary_key: false, on_replace: :update do
      field(:x, :integer)
      field(:y, :integer)
      field(:width, :integer)
      field(:height, :integer)
    end

    embeds_one :extension, Extension, primary_key: false, on_replace: :update do
      embeds_one :rotate, Rotate, primary_key: false, on_replace: :update do
        field(:mode, Ecto.Enum, values: [on: "ON", off: "OFF", auto: "AUTO"])

        embeds_one :extension, Extension, primary_key: false, on_replace: :update do
          embeds_one :lens_description, LensDescription, primary_key: false, on_replace: :update do
            field(:focal_length, :float)
            field(:x_factor, :float)

            embeds_one :lens_offset, LensOffset, primary_key: false, on_replace: :update do
              field(:x, :float)
              field(:y, :float)
            end

            embeds_one :projection, Projection, primary_key: false, on_replace: :update do
              field(:angle, :float)
              field(:radius, :float)
              field(:transmittance, :float)
            end
          end

          embeds_one :scene_orientation, SceneOrientation, primary_key: false, on_replace: :update do
            field(:mode, Ecto.Enum, values: [manual: "MANUAL", auto: "AUTO"])
            field(:orientation, :string)
          end
        end
      end
    end
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      reference_token: ~x"./@token"s,
      view_mode: ~x"./@ViewMode"s,
      name: ~x"./tt:Name/text()"s,
      use_count: ~x"./tt:UseCount/text()"i,
      source_token: ~x"./tt:SourceToken/text()"s,
      bounds: ~x"./tt:Bounds"e |> transform_by(&parse_bounds/1)
    )
  end

  defp parse_bounds(doc) do
    xmap(
      doc,
      x: ~x"./@x"i,
      y: ~x"./@y"i,
      width: ~x"./@width"i,
      height: ~x"./@height"i
    )
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [:reference_token, :name, :use_count, :view_mode, :source_token])
    |> cast_embed(:bounds, with: &bounds_changeset/2)
    |> cast_embed(:extension, with: &extension_changeset/2)
  end

  defp bounds_changeset(module, attrs) do
    cast(module, attrs, [:x, :y, :width, :height])
  end

  defp extension_changeset(module, attrs) do
    module
    |> cast(attrs, [])
    |> cast_embed(:rotate, with: &rotate_changeset/2)
  end

  defp rotate_changeset(module, attrs) do
    module
    |> cast(attrs, [:mode])
    |> cast_embed(:extension, with: &nested_extension_changeset/2)
  end

  defp nested_extension_changeset(module, attrs) do
    module
    |> cast(attrs, [])
    |> cast_embed(:lens_description, with: &lens_description_changeset/2)
    |> cast_embed(:scene_orientation, with: &scene_orientation_changeset/2)
  end

  defp lens_description_changeset(module, attrs) do
    module
    |> cast(attrs, [:focal_length, :x_factor])
    |> cast_embed(:lens_offset, with: &lens_offset_changeset/2)
    |> cast_embed(:projection, with: &projection_changeset/2)
  end

  defp lens_offset_changeset(module, attrs) do
    cast(module, attrs, [:x, :y])
  end

  defp projection_changeset(module, attrs) do
    cast(module, attrs, [:angle, :radius, :transmittance])
  end

  defp scene_orientation_changeset(module, attrs) do
    cast(module, attrs, [:mode, :orientation])
  end
end
