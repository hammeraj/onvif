defmodule Onvif.PTZ.Schemas.ServiceCapabilities do
  @moduledoc """
  Struct representing the service capabilities of a PTZ device.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import SweetXml

  @type t :: %__MODULE__{}

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:eflip, :boolean)
    field(:reverse, :boolean)
    field(:get_compatible_configurations, :boolean)
    field(:move_status, :boolean)
    field(:status_position, :boolean)

    field(:move_and_track, {:array, Ecto.Enum},
      values: [
        preset_token: "PresetToken",
        geo_location: "GeoLocation",
        ptz_vector: "PTZVector",
        object_id: "ObjectID"
      ]
    )
  end

  def to_struct(parsed) do
    %__MODULE__{}
    |> changeset(parsed)
    |> apply_action(:validate)
  end

  def parse(doc) do
    xmap(
      doc,
      eflip: ~x"./@EFlip"s,
      reverse: ~x"./@Reverse"s,
      get_compatible_configurations: ~x"./@GetCompatibleConfigurations"s,
      move_status: ~x"./@MoveStatus"s,
      status_position: ~x"./@StatusPosition"s,
      move_and_track: ~x"./@MoveAndTrack"s |> transform_by(&String.split(&1, " "))
    )
  end

  def changeset(struct, attrs) do
    cast(struct, attrs, __MODULE__.__schema__(:fields))
  end
end
