defmodule Onvif.Device.Service do
  @moduledoc """
  A media profile
  """

  require Logger
  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @profile_permitted [:namespace, :xaddr, :version]

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:namespace, :string)
    field(:xaddr, :string)
    field(:version, :string)
  end

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
    |> apply_action(:validate)
  end

  def changeset(module, attrs) do
    cast(module, attrs, @profile_permitted)
  end
end
