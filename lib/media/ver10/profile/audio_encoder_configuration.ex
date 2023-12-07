defmodule Onvif.Media.Ver10.Profile.AudioEncoderConfiguration do
  @moduledoc """
  Optional configuration of the Audio encoder.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  alias Onvif.Media.Ver10.Profile.MulticastConfiguration

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:reference_token, :string)
    field(:name, :string)
    field(:use_count, :integer)

    field(:encoding, Ecto.Enum,
      values: [g711: "G711", g726: "G726", aac: "AAC", pcmu: "PCMU", pcma: "PCMA"]
    )

    field(:bitrate, :integer)
    field(:sample_rate, :integer)
    field(:session_timeout, :string)

    embeds_one(:multicast_configuration, MulticastConfiguration)
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      reference_token: ~x"./@token"s,
      name: ~x"./tt:Name/text()"s,
      use_count: ~x"./tt:UseCount/text()"i,
      encoding: ~x"./tt:Encoding/text()"s,
      bitrate: ~x"./tt:Bitrate/text()"i,
      sample_rate: ~x"./tt:SampleRate/text()"i,
      session_timeout: ~x"./tt:SessionTimeout/text()"s,
      multicast_configuration:
        ~x"./tt:Multicast"e |> transform_by(&MulticastConfiguration.parse/1)
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(%Onvif.Media.Ver10.Profile.AudioEncoderConfiguration{}) ::
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
    |> cast(attrs, [
      :reference_token,
      :name,
      :use_count,
      :encoding,
      :bitrate,
      :sample_rate,
      :session_timeout
    ])
    |> cast_embed(:multicast_configuration)
  end
end
