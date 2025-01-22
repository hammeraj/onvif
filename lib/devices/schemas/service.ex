defmodule Onvif.Devices.Schemas.Service do
  @moduledoc """
  A media profile
  """

  require Logger
  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @required [:namespace, :xaddr, :version]

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:namespace, :string)
    field(:xaddr, :string)
    field(:version, :string)
  end

  def parse(nil), do: nil
  def parse([]), do: nil

  def parse(doc) do
    version =
      xmap(doc,
        major: ~x"./tds:Version/tt:Major/text()"s,
        minor: ~x"./tds:Version/tt:Minor/text()"s
      )

    doc
    |> xmap(
      namespace: ~x"./tds:Namespace/text()"s,
      xaddr: ~x"./tds:XAddr/text()"s
    )
    |> Map.put(:version, "#{version.major}.#{version.minor}")
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> validate_required(@required)
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

  def changeset(module, attrs) do
    cast(module, attrs, @required)
  end
end
