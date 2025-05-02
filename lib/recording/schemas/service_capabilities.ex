defmodule Onvif.Recording.Schemas.ServiceCapabilities do
  @moduledoc """
  Struct representing recording's service capabilities.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:dynamic_tracks, :boolean)
    field(:dynamic_recordings, :boolean)
    field(:encoding, {:array, :string})
    field(:max_rate, :float)
    field(:max_total_rate, :float)
    field(:max_recordings, :float)
    field(:max_recording_jobs, :float)
    field(:options, :boolean)
    field(:metadata_recording, :boolean, default: false)
    field(:supported_export_file_formats, {:array, :string})
    field(:event_recording, :boolean, default: false)
    field(:before_event_limit, :integer)
    field(:after_event_limit, :integer)
    field(:supported_target_formats, {:array, :string})
    field(:encryption_entry_limit, :integer)
    field(:supported_encryption_modes, {:array, :string})
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  def parse(doc) do
    xmap(
      doc,
      dynamic_tracks: ~x"./@DynamicTracks"s,
      dynamic_recordings: ~x"./@DynamicRecordings"s,
      encoding: ~x"./@Encoding"s |> transform_by(&String.split(&1, " ")),
      max_rate: ~x"./@MaxRate"f,
      max_total_rate: ~x"./@MaxTotalRate"f,
      max_recordings: ~x"./@MaxRecordings"f,
      max_recording_jobs: ~x"./@MaxRecordingJobs"f,
      options: ~x"./@Options"s,
      metadata_recording: ~x"./@MetadataRecording"s,
      supported_export_file_formats:
        ~x"./@SupportedExportFileFormats"s |> transform_by(&String.split(&1, " ")),
      event_recording: ~x"./@EventRecording"s,
      before_event_limit: ~x"./@BeforeEventLimit"io,
      after_event_limit: ~x"./@AfterEventLimit"io,
      supported_target_formats:
        ~x"./@SupportedTargetFormats"s |> transform_by(&String.split(&1, " ")),
      encryption_entry_limit: ~x"./@EncryptionEntryLimit"io,
      supported_encryption_modes:
        ~x"./@SupportedEncryptionModes"s |> transform_by(&String.split(&1, " "))
    )
  end

  def changeset(struct, attrs) do
    cast(struct, attrs, __MODULE__.__schema__(:fields))
  end
end
