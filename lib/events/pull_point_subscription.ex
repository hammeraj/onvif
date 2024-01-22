defmodule Onvif.Events.PullPointSubscription do
  @moduledoc """
  Return payload for a pull point subscription
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:address, :string)
    field(:current_time, :utc_datetime)
    field(:termination_time, :utc_datetime)
  end

  def parse(nil), do: nil

  def parse(doc) do
    xmap(
      doc,
      address: ~x"./tev:SubscriptionReference/wsa:Address/text()"s,
      current_time: ~x"./wsnt:CurrentTime/text()"s,
      termination_time: ~x"./wsnt:TerminationTime/text()"s
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
      :address,
      :current_time,
      :termination_time
    ])
  end
end
