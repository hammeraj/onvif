defmodule Onvif.Events.Message do
  @moduledoc """
  Return payload for a pull point message
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:topic, :string)
    field(:utc_time, :utc_datetime)
    field(:property_operation, :string)
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      topic: ~x"./wsnt:Topic/text()"s,
      utc_time: ~x"./wsnt:Message/tt:Message/@UtcTime"s,
      property_operation: ~x"./wsnt:Message/tt:Message/@PropertyOperation"s
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  @spec to_json(%__MODULE__{}) ::
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
    cast(module, attrs, [
      :topic,
      :utc_time,
      :property_operation
    ])
  end
end
