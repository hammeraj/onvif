defmodule Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption do
  @moduledoc """
  Optional configuration of the Audio encoder.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  @required []
  @optional []

  embedded_schema do
    embeds_many :options, Options, primary_key: false, on_replace: :delete do
      @derive Jason.Encoder
      field(:encoding, Ecto.Enum, values: [G711: "G711", G726: "G726", AAC: "AAC"])

      embeds_one :bitrate_list, BitrateList, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:items, {:array, :integer})
      end

      embeds_one :sample_rate_list, SampleRateList, primary_key: false, on_replace: :update do
        @derive Jason.Encoder
        field(:items, {:array, :integer})
      end
    end
  end

  def parse(nil), do: nil
  def parse([]), do: nil

  def parse(doc) do
    xmap(
      doc,
      options: ~x"./tt:Options"elo |> transform_by(&parse_options/1)
    )
  end

  def parse_options(nil), do: nil
  def parse_options([]), do: nil

  def parse_options(docs) do
    Enum.map(docs, fn doc ->
      xmap(
        doc,
        encoding: ~x"./tt:Encoding/text()"so,
        bitrate_list: ~x"./tt:BitrateList"eo |> transform_by(&parse_unbound_int_list/1),
        sample_rate_list: ~x"./tt:SampleRateList"eo |> transform_by(&parse_unbound_int_list/1)
      )
    end)
  end

  def parse_unbound_int_list(nil), do: nil
  def parse_unbound_int_list([]), do: nil

  def parse_unbound_int_list(doc) do
    xmap(
      doc,
      items: ~x"./tt:Items/text()"ilo
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(%Onvif.Media.Ver10.Profile.AudioEncoderConfigurationOption{}) ::
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
    |> cast_embed(:options, with: &options_changeset/2)
  end

  def options_changeset(module, attrs) do
    cast(module, attrs, [:encoding])
    |> cast_embed(:bitrate_list, with: &unbound_int_list_changeset/2)
    |> cast_embed(:sample_rate_list, with: &unbound_int_list_changeset/2)
  end

  def unbound_int_list_changeset(module, attrs) do
    cast(module, attrs, [:items])
  end
end
