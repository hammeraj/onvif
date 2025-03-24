defmodule Onvif.Schemas.FloatRange do
  @moduledoc """
  Module describing a float range.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml
  import XmlBuilder

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:min, :float)
    field(:max, :float)
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      min: ~x"./tt:Min/text()"s,
      max: ~x"./tt:Max/text()"s
    )
  end

  def to_xml(struct) do
    [
      element(:"tt:Min", struct.min),
      element(:"tt:Max", struct.max)
    ]
  end

  def changeset(struct, attrs) do
    cast(struct, attrs, [:min, :max])
  end
end
