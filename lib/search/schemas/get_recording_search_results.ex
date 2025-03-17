defmodule Onvif.Search.Schemas.GetRecordingSearchResults do
  @moduledoc """
  Module describing the request to `Onvif.Search.GetRecordingSearchResults`.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import XmlBuilder

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:search_token, :string)
    field(:min_results, :integer)
    field(:max_results, :integer)
    field(:wait_time, :integer)
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
      :"tse:GetRecordingSearchResults",
      [element(:"tse:SearchToken", schema.search_token)]
      |> xml_min_results(schema.min_results)
      |> xml_max_results(schema.max_results)
      |> xml_wait_time(schema.wait_time)
    )
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required([:search_token])
  end

  defp xml_max_results(body, nil), do: body

  defp xml_max_results(body, max_results) do
    [element(:"tse:MaxResults", max_results) | body]
  end

  defp xml_min_results(body, nil), do: body

  defp xml_min_results(body, min_results) do
    [element(:"tse:MinResults", min_results) | body]
  end

  defp xml_wait_time(body, nil), do: body

  defp xml_wait_time(body, time) do
    [element(:"tse:WaitTime", "PT#{time}S") | body]
  end
end
