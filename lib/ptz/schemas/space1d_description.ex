defmodule Onvif.PTZ.Schemas.Space1DDescription do
  @moduledoc """
  Module describing a 1D space.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml

  alias Onvif.Schemas.FloatRange

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:uri, :string)
    embeds_one(:x_range, FloatRange)
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      uri: ~x"./tt:URI/text()"s,
      x_range: ~x"./tt:XRange"e |> transform_by(&FloatRange.parse/1)
    )
  end

  def changeset(space1d_description, attrs) do
    space1d_description
    |> cast(attrs, [:uri])
    |> cast_embed(:x_range, with: &FloatRange.changeset/2)
  end
end
