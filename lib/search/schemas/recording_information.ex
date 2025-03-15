defmodule Onvif.Search.Schemas.RecordingInformation do
  @moduledoc """
  A module describing recording information.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:recording_token, :string)

    embeds_one :source, RecordingSourceInformation, primary_key: false do
      @derive Jason.Encoder
      field(:source_id, :string)
      field(:name, :string)
      field(:location, :string)
      field(:description, :string)
      field(:address, :string)
    end

    field(:earliest_recording, :utc_datetime)
    field(:latest_recording, :utc_datetime)
    field(:content, :string)

    embeds_many :tracks, TrackInformation, primary_key: false, on_replace: :delete do
      @derive Jason.Encoder
      field(:track_token, :string)

      field(:track_type, Ecto.Enum, values: [audio: "Audio", video: "Video", metadata: "Metadata"])

      field(:description, :string)
      field(:data_from, :utc_datetime)
      field(:data_to, :utc_datetime)
    end

    field(:recording_status, Ecto.Enum,
      values: [
        initiated: "Initiated",
        recording: "Recording",
        stopped: "Stopped",
        removing: "Removing",
        removed: "Removed",
        unknown: "Unknown"
      ]
    )
  end

  def parse(docs) do
    docs
    |> List.wrap()
    |> Enum.map(fn doc ->
      xmap(
        doc,
        recording_token: ~x"./tt:RecordingToken/text()"s,
        source: [
          ~x"./tt:Source"e,
          source_id: ~x"./tt:SourceId/text()"s,
          name: ~x"./tt:Name/text()"s,
          location: ~x"./tt:Location/text()"s,
          description: ~x"./tt:Description/text()"s,
          address: ~x"./tt:Address/text()"s
        ],
        earliest_recording: ~x"./tt:EarliestRecording/text()"s,
        latest_recording: ~x"./tt:LatestRecording/text()"s,
        content: ~x"./tt:Content/text()"s,
        recording_status: ~x"./tt:RecordingStatus/text()"s,
        tracks: ~x"./tt:Track"el |> transform_by(&parse_track_information/1)
      )
    end)
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

  def changeset(module, attrs) do
    module
    |> cast(attrs, [
      :recording_token,
      :earliest_recording,
      :latest_recording,
      :content,
      :recording_status
    ])
    |> cast_embed(:source, with: &recording_source_changeset/2)
    |> cast_embed(:tracks, with: &track_information_changeset/2)
  end

  defp parse_track_information(docs) do
    docs
    |> List.wrap()
    |> Enum.map(fn doc ->
      xmap(
        doc,
        track_token: ~x"./tt:TrackToken/text()"s,
        track_type: ~x"./tt:TrackType/text()"s,
        description: ~x"./tt:Description/text()"s,
        data_from: ~x"./tt:DataFrom/text()"s,
        data_to: ~x"./tt:DataTo/text()"s
      )
    end)
  end

  defp recording_source_changeset(module, attrs) do
    cast(module, attrs, [
      :source_id,
      :name,
      :location,
      :description,
      :address
    ])
  end

  defp track_information_changeset(module, attrs) do
    cast(module, attrs, [
      :track_token,
      :track_type,
      :description,
      :data_from,
      :data_to
    ])
  end
end
