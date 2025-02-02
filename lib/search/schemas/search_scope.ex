defmodule Onvif.Search.Schemas.SearchScope do
  @moduledoc """
  A module representing a schema for search scope.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import XmlBuilder

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    embeds_many :included_sources, SourceReference, primary_key: false do
      @derive Jason.Encoder
      field(:token, :string)
      field(:type, :string)
    end

    field(:included_recordings, {:array, :string})
    field(:recording_information_format, :string)
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(__MODULE__.t()) ::
          {:error,
           %{
             :__exception__ => any,
             :__struct__ => Jason.EncodeError | Protocol.UndefinedError,
             optional(atom) => any
           }}
          | {:ok, binary}
  def to_json(%__MODULE__{} = schema) do
    Jason.encode(schema)
  end

  def to_xml(nil) do
    element(:"tse:Scope", [])
  end

  def to_xml(%__MODULE__{} = schema) do
    element(:"tse:Scope", [
      Enum.map(schema.included_sources, fn is ->
        element(:"tt:IncludedSources", [
          element(:"tt:Token", is.token),
          element(:"tt:Type", is.type)
        ])
      end),
      Enum.map(schema.included_recordings, &element(:"tt:IncludedRecordings", &1)),
      element(:"tt:RecordingInformationFormat", [schema.recording_information_format])
    ])
  end

  defp changeset(module, attrs) do
    module
    |> cast(attrs, [:included_recordings, :recording_information_format])
    |> cast_embed(:included_sources, with: &included_sources_changeset/2)
  end

  defp included_sources_changeset(module, attrs) do
    module
    |> cast(attrs, [:token, :type])
    |> validate_required([:token])
  end
end
