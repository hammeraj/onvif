defmodule Onvif.Media.Ver10.Profile.Parameters do
  @moduledoc """

  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    embeds_many :simple_item, SimpleItem, primary_key: false do
      @derive Jason.Encoder
      field(:name, :string)
      field(:value, :string)
    end

    embeds_many :element_item, ElementItem, primary_key: false do
      @derive Jason.Encoder
      field(:name, :string)
    end
  end

  def parse([]), do: []

  def parse(doc) do
    xmap(
      doc,
      simple_item: ~x"./tt:SimpleItem"el |> transform_by(&parse_simple_item/1),
      element_item: ~x"./tt:ElementItem"el |> transform_by(&parse_element_item/1)
    )
  end

  defp parse_simple_item(nil), do: []
  defp parse_simple_item([]), do: []

  defp parse_simple_item([_ | _] = simple_items), do: Enum.map(simple_items, &parse_simple_item/1)

  defp parse_simple_item(doc) do
    xmap(
      doc,
      name: ~x"./@Name"s,
      value: ~x"./@Value"s
    )
  end

  defp parse_element_item(nil), do: []
  defp parse_element_item([]), do: []

  defp parse_element_item([_ | _] = element_items),
    do: Enum.map(element_items, &parse_element_item/1)

  defp parse_element_item(doc) do
    xmap(
      doc,
      name: ~x"./@Name"s
    )
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [])
    |> cast_embed(:simple_item, with: &simple_item_changeset/2)
    |> cast_embed(:element_item, with: &element_item_changeset/2)
  end

  defp simple_item_changeset(module, attrs) do
    cast(module, attrs, [:name, :value])
  end

  defp element_item_changeset(module, attrs) do
    cast(module, attrs, [:name])
  end
end
