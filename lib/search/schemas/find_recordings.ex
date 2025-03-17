defmodule Onvif.Search.Schemas.FindRecordings do
  @moduledoc """
  Module describing the FindRecordings schema.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import XmlBuilder

  alias Onvif.Search.Schemas.SearchScope

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:max_matches, :integer)
    field(:keep_alive_time, :integer)

    embeds_one(:scope, SearchScope)
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

  def to_xml(%__MODULE__{} = schema) do
    element(
      :"tse:FindRecordings",
      [SearchScope.to_xml(schema.scope)]
      |> xml_max_matches(schema.max_matches)
      |> xml_keep_alive_time(schema.keep_alive_time)
    )
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [:max_matches, :keep_alive_time])
    |> validate_required([:keep_alive_time])
    |> cast_embed(:scope)
  end

  defp xml_max_matches(body, nil), do: body

  defp xml_max_matches(body, max_matches) do
    [element(:"tse:MaxMatches", max_matches) | body]
  end

  defp xml_keep_alive_time(body, nil), do: body

  defp xml_keep_alive_time(body, time) do
    [element(:"tse:KeepAliveTime", "PT#{time}S") | body]
  end
end
