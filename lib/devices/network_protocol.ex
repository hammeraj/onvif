defmodule Onvif.Devices.NetworkProtocol do
  @moduledoc """
  A module describing a network protocol.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml

  @required [:name, :enabled, :port]

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:name, Ecto.Enum, values: [http: "HTTP", https: "HTTPS", rtsp: "RTSP"])
    field(:enabled, :boolean)
    field(:port, :integer)
  end

  def to_json(%__MODULE__{} = schema) do
    Jason.encode(schema)
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> validate_required(@required)
    |> apply_action(:validate)
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, @required)
    |> validate_required(@required)
  end

  def parse(doc) do
    xmap(doc,
      name: ~x"./tt:Name/text()"s,
      enabled: ~x"./tt:Enabled/text()"s,
      port: ~x"./tt:Port/text()"s
    )
  end
end
