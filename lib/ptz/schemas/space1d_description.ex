defmodule Onvif.PTZ.Schemas.Space1DDescription do
  @moduledoc """
  Module describing a 1D space.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:uri, :string)

    embeds_one :x_range, FloatRange, primary_key: false do
      @derive Jason.Encoder
      field(:min, :float)
      field(:max, :float)
    end
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      uri: ~x"./tt:URI/text()"s,
      x_range: ~x"./tt:XRange"e |> transform_by(&parse_range/1)
    )
  end

  def changeset(space1d_description, attrs) do
    space1d_description
    |> cast(attrs, [:uri])
    |> cast_embed(:x_range, with: &range_changeset(&1, &2))
  end

  defp parse_range(doc) do
    xmap(
      doc,
      min: ~x"./tt:Min/text()"s,
      max: ~x"./tt:Max/text()"s
    )
  end

  defp range_changeset(module, attrs) do
    cast(module, attrs, [:min, :max])
  end
end
