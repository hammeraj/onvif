defmodule Onvif.Media.Ver10.Profile.AudioSourceConfiguration do
  @moduledoc """

  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:reference_token, :string)
    field(:name, :string)
    field(:use_count, :integer)
    field(:source_token, :string)
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      reference_token: ~x"./@token"s,
      name: ~x"./tt:Name/text()"s,
      use_count: ~x"./tt:UseCount/text()"i,
      source_token: ~x"./tt:SourceToken/text()"s
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(%Onvif.Media.Ver10.Profile.AudioSourceConfiguration{}) ::
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
    cast(module, attrs, [:reference_token, :name, :use_count, :source_token])
  end
end
