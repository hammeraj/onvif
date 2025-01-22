defmodule Onvif.Devices.Schemas.DeviceInformation do
  @moduledoc """
  DeviceInformation schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @required [:manufacturer, :model, :firmware_version, :serial_number, :hardware_id]

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:manufacturer, :string)
    field(:model, :string)
    field(:firmware_version, :string)
    field(:serial_number, :string)
    field(:hardware_id, :string)
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      manufacturer: ~x"./tds:Manufacturer/text()"s,
      model: ~x"./tds:Model/text()"s,
      firmware_version: ~x"./tds:FirmwareVersion/text()"s,
      serial_number: ~x"./tds:SerialNumber/text()"s,
      hardware_id: ~x"./tds:HardwareId/text()"s
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  def to_json(%__MODULE__{} = schema) do
    Jason.encode(schema)
  end

  def changeset(module, attrs) do
    cast(module, attrs, @required)
  end
end
