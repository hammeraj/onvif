defmodule Onvif.Devices.NTP do
  @moduledoc """
  Schema for the NTP configuration to be used with SetNTP and GetNTP operations.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @primary_key false
  @derive Jason.Encoder
  @required [:from_dhcp]
  @optional []

  embedded_schema do
    field(:from_dhcp, :boolean)

    embeds_one :ntp_manual, NTPManual, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:type, Ecto.Enum, values: [ipv4: "IPv4", ipv6: "IPv6", dns: "DNS"])
      field(:ipv4_address, :string)
      field(:ipv6_address, :string)
      field(:dns_name, :string)
    end

    embeds_one :ntp_from_dhcp, NTPFromDHCP, primary_key: false, on_replace: :update do
      @derive Jason.Encoder
      field(:type, Ecto.Enum, values: [ipv4: "IPv4", ipv6: "IPv6", dns: "DNS"])
      field(:ipv4_address, :string)
      field(:ipv6_address, :string)
      field(:dns_name, :string)
    end
  end

  def parse(nil), do: %{}
  def parse([]), do: %{}

  def parse(doc) do
    xmap(
      doc,
      from_dhcp: ~x"./tt:FromDHCP/text()"so,
      ntp_from_dhcp: ~x"./tt:NTPFromDHCP"eo |> transform_by(&parse_ntp_data/1),
      ntp_manual: ~x"./tt:NTPManual"eo |> transform_by(&parse_ntp_data/1)
    )
  end

  def parse_ntp_data([]), do: nil
  def parse_ntp_data(nil), do: nil

  def parse_ntp_data(doc) do
    xmap(
      doc,
      type: ~x"./tt:Type/text()"so,
      ipv4_address: ~x"./tt:IPv4Address/text()"so,
      ipv6_address: ~x"./tt:IPv6Address/text()"so,
      dns_name: ~x"./tt:DNSname/text()"so
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
    module
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:ntp_from_dhcp, with: &ntp_data_changeset/2)
    |> cast_embed(:ntp_manual, with: &ntp_data_changeset/2)
  end

  def ntp_data_changeset(module, attrs) do
    cast(module, attrs, [:type, :ipv4_address, :ipv6_address, :dns_name])
  end
end
