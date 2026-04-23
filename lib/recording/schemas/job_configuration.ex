defmodule Onvif.Recording.Schemas.JobConfiguration do
  @moduledoc """
  Schema describing a recording job configuration.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml
  import XmlBuilder

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:recording_token, :string)
    field(:mode, Ecto.Enum, values: [idle: "Idle", active: "Active"])
    field(:priority, :integer)

    embeds_one :source, Source, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:auto_create_receiver, :boolean)

      embeds_one :source_token, SourceToken, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:token, :string)
      end

      embeds_many :tracks, Tracks, primary_key: false, on_replace: :delete do
        @derive Jason.Encoder
        field(:source_tag, :string)
        field(:destination, :string)
      end
    end
  end

  def parse([]), do: nil
  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      recording_token: ~x"./tt:RecordingToken/text()"so,
      mode: ~x"./tt:Mode/text()"so,
      priority: ~x"./tt:Priority/text()"so,
      source: ~x"./tt:Source"eo |> transform_by(&parse_source/1)
    )
  end

  def to_xml(%__MODULE__{} = job_configuration) do
    field_to_xml([], "tt:RecordingToken", job_configuration.recording_token)
    |> field_to_xml(
      "tt:Mode",
      Keyword.get(Ecto.Enum.mappings(__MODULE__, :mode), job_configuration.mode)
    )
    |> field_to_xml("tt:Priority", job_configuration.priority)
    |> source_to_xml(job_configuration.source)
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  def changeset(job_configuration, attrs) do
    job_configuration
    |> cast(attrs, [:recording_token, :mode, :priority])
    |> cast_embed(:source, with: &source_changeset/2)
  end

  defp parse_source([]), do: nil
  defp parse_source(nil), do: nil

  defp parse_source(doc) do
    xmap(
      doc,
      source_token: ~x"./tt:SourceToken"eo |> transform_by(&parse_source_token/1),
      auto_create_receiver: ~x"./tt:AutoCreateReceiver/text()"so,
      tracks: ~x"./tt:Tracks"elo |> transform_by(&parse_track/1)
    )
  end

  defp parse_source_token([]), do: nil
  defp parse_source_token(nil), do: nil

  defp parse_source_token(doc) do
    xmap(
      doc,
      token: ~x"./tt:Token/text()"so
    )
  end

  defp parse_track([]), do: nil
  defp parse_track(nil), do: nil

  defp parse_track(docs) do
    Enum.map(docs, fn doc ->
      xmap(
        doc,
        source_tag: ~x"./tt:SourceTag/text()"so,
        destination: ~x"./tt:Destination/text()"so
      )
    end)
  end

  defp source_changeset(schema, params) do
    schema
    |> cast(params, [:auto_create_receiver])
    |> cast_embed(:source_token, with: &source_token_changeset/2)
    |> cast_embed(:tracks, with: &track_changeset/2)
  end

  defp source_token_changeset(schema, params) do
    schema
    |> cast(params, [:token])
    |> validate_required([:token])
  end

  defp track_changeset(schema, params) do
    schema
    |> cast(params, [:source_tag, :destination])
  end

  defp source_to_xml(builder, nil), do: builder

  defp source_to_xml(builder, source) do
    source =
      element(
        "tt:Source",
        field_to_xml([], "tt:AutoCreateReceiver", source.auto_create_receiver)
        |> source_token_to_xml(source.source_token)
        |> tracks_to_xml(source.tracks)
      )

    [source | builder]
  end

  defp source_token_to_xml(builder, nil), do: builder

  defp source_token_to_xml(builder, source_token) do
    source_token = element("tt:SourceToken", field_to_xml([], "tt:Token", source_token.token))
    [source_token | builder]
  end

  defp tracks_to_xml(builder, nil), do: builder
  defp tracks_to_xml(builder, []), do: builder

  defp tracks_to_xml(builder, tracks) do
    tracks =
      Enum.map(tracks, fn track ->
        element(
          "tt:Tracks",
          field_to_xml([], "tt:SourceTag", track.source_tag)
          |> field_to_xml("tt:Destination", track.destination)
        )
      end)

    [tracks | builder]
  end

  defp field_to_xml(builder, _field, nil), do: builder

  defp field_to_xml(builder, key, value) do
    [element(key, value) | builder]
  end
end
