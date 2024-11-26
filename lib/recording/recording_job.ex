defmodule Onvif.Recording.RecordingJob do
  @moduledoc """
  Recordings.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  @required [:job_token]
  @optional []

  embedded_schema do
    field(:job_token, :string)

    embeds_one :job_configuration, JobConfiguration, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:recording_token, :string)
      field(:mode, :string)
      field(:priority, :string)

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
  end

  def parse(nil), do: nil
  def parse([]), do: nil

  def parse(doc) do
    xmap(
      doc,
      job_token: ~x"./tt:JobToken/text()"so,
      job_configuration: ~x"./tt:JobConfiguration"eo |> transform_by(&parse_job_configuration/1)
    )
  end

  def parse_job_configuration([]), do: nil
  def parse_job_configuration(nil), do: nil

  def parse_job_configuration(doc) do
    xmap(
      doc,
      recording_token: ~x"./tt:RecordingToken/text()"so,
      mode: ~x"./tt:Mode/text()"so,
      priority: ~x"./tt:Priority/text()"so,
      source: ~x"./tt:Source"eo |> transform_by(&parse_source/1)
    )
  end

  def parse_source([]), do: nil
  def parse_source(nil), do: nil

  def parse_source(doc) do
    xmap(
      doc,
      source_token: ~x"./tt:SourceToken"eo |> transform_by(&parse_source_token/1),
      auto_create_receiver: ~x"./tt:AutoCreateReceiver/text()"so,
      tracks: ~x"./tt:Tracks"elo |> transform_by(&parse_track/1)
    )
  end

  def parse_source_token([]), do: nil
  def parse_source_token(nil), do: nil

  def parse_source_token(doc) do
    xmap(
      doc,
      token: ~x"./tt:Token/text()"so
    )
  end

  def parse_track([]), do: nil
  def parse_track(nil), do: nil

  def parse_track(docs) do
    Enum.map(docs, fn doc ->
      xmap(
        doc,
        source_tag: ~x"./tt:SourceTag/text()"so,
        destination: ~x"./tt:Destination/text()"so
      )
    end)
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(%Onvif.Recording.RecordingJob{}) ::
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
    |> cast_embed(:job_configuration, with: &job_configuration_changeset/2)
  end

  def job_configuration_changeset(schema, params) do
    schema
    |> cast(params, [:recording_token, :mode, :priority])
    |> validate_required([:recording_token, :mode, :priority])
    |> cast_embed(:source, with: &source_changeset/2)
  end

  def source_changeset(schema, params) do
    schema
    |> cast(params, [:auto_create_receiver])
    |> cast_embed(:source_token, with: &source_token_changeset/2)
    |> cast_embed(:tracks, with: &track_changeset/2)
  end

  def source_token_changeset(schema, params) do
    schema
    |> cast(params, [:token])
    |> validate_required([:token])
  end

  def track_changeset(schema, params) do
    schema
    |> cast(params, [:source_tag, :destination])
  end
end
