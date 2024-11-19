defmodule Onvif.Recording.Recordings do
  @moduledoc """
  Recordings.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  @required [:recording_token]
  @optional []

  embedded_schema do
    field(:recording_token, :string)

    embeds_one :configuration, Configuration, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:content, :string)
      field(:maximum_retention_time, :string)
      embeds_one(:source, Source, primary_key: false, on_replace: :update) do
        @derive Jason.Encoder
        field(:source_id, :string)
        field(:name, :string)
        field(:location, :string)
        field(:description, :string)
        field(:address, :string)
      end
    end

    embeds_one(:tracks, Tracks, primary_key: false, on_replace: :update) do
      @derive Jason.Encoder
      embeds_many(:track, Track, primary_key: false, on_replace: :delete) do
        @derive Jason.Encoder
        field(:track_token, :string)
        embeds_one(:configuration, Configuration, primary_key: false, on_replace: :update) do
          @derive Jason.Encoder
          field(:track_type, :string)
          field(:description, :string)
        end
      end
    end
  end

  def parse(nil), do: nil
  def parse([]), do: nil
  def parse(doc) do
    xmap(
      doc,
      recording_token: ~x"./tt:RecordingToken/text()"so,
      configuration: ~x"./tt:Configuration"eo |> transform_by(&parse_configuration/1),
      tracks: ~x"./tt:Tracks"eo |> transform_by(&parse_tracks/1),
    )
  end

  def parse_configuration([]), do: nil
  def parse_configuration(nil), do: nil
  def parse_configuration(doc) do
    xmap(
      doc,
      content: ~x"./tt:Content/text()"so,
      maximum_retention_time: ~x"./tt:MaximumRetentionTime/text()"so,
      source: ~x"./tt:Source"eo |> transform_by(&parse_source/1)
    )
  end

  def parse_source([]), do: nil
  def parse_source(nil), do: nil
  def parse_source(doc) do
    xmap(
      doc,
      source_id: ~x"./tt:SourceId/text()"so,
      name: ~x"./tt:Name/text()"so,
      location: ~x"./tt:Location/text()"so,
      description: ~x"./tt:Description/text()"so,
      address: ~x"./tt:Address/text()"so
    )
  end

  def parse_tracks([]), do: nil
  def parse_tracks(nil), do: nil
  def parse_tracks(doc) do
    xmap(
      doc,
      track: ~x"./tt:Track"elo |> transform_by(&parse_track/1)
    )
  end

  def parse_track([]), do: nil
  def parse_track(nil), do: nil
  def parse_track(doc) do
    xmap(
      doc,
      track_token: ~x"./tt:TrackToken/text()"so,
      configuration: ~x"./tt:Configuration"eo |> transform_by(&parse_track_configuration/1)
    )
  end

  def parse_track_configuration([]), do: nil
  def parse_track_configuration(nil), do: nil
  def parse_track_configuration(doc) do
    xmap(
      doc,
      track_type: ~x"./tt:TrackType/text()"so,
      description: ~x"./tt:Description/text()"so
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(%Onvif.Recording.Recordings{}) ::
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

  def changeset(module, attrs) do
    module
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:configuration, with: &configuration_changeset/2)
    |> cast_embed(:tracks, with: &tracks_changeset/2)
  end

  def configuration_changeset(module, attrs) do
    cast(module, attrs, [:content, :maximum_retention_time])
    |> cast_embed(:source, with: &source_changeset/2)
  end

  def source_changeset(module, attrs) do
    cast(module, attrs, [:source_id, :name, :location, :description, :address])
  end

  def tracks_changeset(module, attrs) do
    cast(module, attrs, [])
    |> cast_embed(:track, with: &track_changeset/2)
  end

  def track_changeset(module, attrs) do
    cast(module, attrs, [:track_token])
    |> cast_embed(:configuration, with: &track_configuration_changeset/2)
  end

  def track_configuration_changeset(module, attrs) do
    cast(module, attrs, [:track_type, :description])
  end

end
