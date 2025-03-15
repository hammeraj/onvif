defmodule Onvif.Search.Schemas.FindRecordingResult do
  @moduledoc """
  A module describing results from `Onvif.Search.GetRecordingSearchResults.request/2`.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml

  alias Onvif.Search.Schemas.RecordingInformation

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:search_state, Ecto.Enum,
      values: [
        queued: "Queued",
        searching: "Searching",
        completed: "Completed",
        unknown: "Unknown"
      ]
    )

    embeds_many(:recording_information, RecordingInformation)
  end

  def parse(doc) do
    xmap(
      doc,
      search_state: ~x"./tt:SearchState/text()"s,
      recording_information:
        ~x"./tt:RecordingInformation"el |> transform_by(&RecordingInformation.parse/1)
    )
  end

  @spec to_struct(map()) :: {:error, Ecto.Changeset.t()} | {:ok, __MODULE__.t()}
  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(__MODULE__.t()) :: {:error, Jason.EncodeError.t() | Exception.t()} | {:ok, binary}
  def to_json(%__MODULE__{} = schema) do
    Jason.encode(schema)
  end

  defp changeset(module, attrs) do
    module
    |> cast(attrs, [:search_state])
    |> cast_embed(:recording_information)
  end
end
