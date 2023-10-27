defmodule Onvif.Media.Ver10.Profile.AnalyticsEngineConfiguration do
  @moduledoc """
  Indication which AnalyticsModules shall output metadata. Note that the streaming behavior is undefined if the list includes items that are not part of the associated AnalyticsConfiguration.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  alias Onvif.Media.Ver10.Profile.Parameters

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    @derive Jason.Encoder
    embeds_many :analytics_module, AnalyticsModule, primary_key: false, on_replace: :delete do
      field(:name, :string)
      field(:type, :string)

      embeds_one(:parameters, Parameters)
    end
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      analytics_module: ~x"./tt:AnalyticsModule"el |> transform_by(&parse_analytics_module/1)
    )
  end

  defp parse_analytics_module(nil), do: nil

  defp parse_analytics_module([_ | _] = analytics_modules),
    do: Enum.map(analytics_modules, &parse_analytics_module/1)

  defp parse_analytics_module(doc) do
    xmap(
      doc,
      name: ~x"./@Name"s,
      type: ~x"./@Type"s,
      parameters: ~x"./tt:Parameters"e |> transform_by(&Parameters.parse/1)
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [])
    |> cast_embed(:analytics_module, with: &analytics_module_changeset/2)
  end

  defp analytics_module_changeset(module, attrs) do
    module
    |> cast(attrs, [:name, :type])
    |> cast_embed(:parameters)
  end
end
