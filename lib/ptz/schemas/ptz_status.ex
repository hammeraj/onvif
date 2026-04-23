defmodule Onvif.PTZ.Schemas.PTZStatus do
  @moduledoc """
  Module describing PTZ Status schema
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml

  alias Onvif.PTZ.Schemas.PTZVector

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    embeds_one(:position, PTZVector)

    embeds_one :move_status, MoveStatus, primary_key: false do
      @derive Jason.Encoder
      field(:pan_tilt, Ecto.Enum, values: [idle: "IDLE", moving: "MOVING", unknown: "UNKNOWN"])
      field(:zoom, Ecto.Enum, values: [idle: "IDLE", moving: "MOVING", unknown: "UNKNOWN"])
    end

    field(:utc_time, :utc_datetime)
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(__MODULE__.t()) :: {:error, Jason.EncodeError.t() | Exception.t()} | {:ok, binary}
  def to_json(struct), do: Jason.encode(struct)

  def parse(doc) do
    xmap(
      doc,
      position: ~x"./tt:Position" |> transform_by(&PTZVector.parse/1),
      move_status: ~x"./tt:MoveStatus"e |> transform_by(&parse_move_status/1),
      utc_time: ~x"./tt:UtcTime/text()"s
    )
  end

  def parse_move_status(doc) do
    xmap(
      doc,
      pan_tilt: ~x"./tt:PanTilt/text()"s,
      zoom: ~x"./tt:Zoom/text()"s
    )
  end

  def changeset(ptz_status, attrs) do
    ptz_status
    |> cast(attrs, [:utc_time])
    |> cast_embed(:position, with: &PTZVector.changeset/2)
    |> cast_embed(:move_status, with: &move_status_changeset/2)
  end

  defp move_status_changeset(ptz_status, attrs) do
    ptz_status
    |> cast(attrs, [:pan_tilt, :zoom])
  end
end
