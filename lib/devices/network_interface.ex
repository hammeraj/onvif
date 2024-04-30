defmodule Onvif.Device.NetworkInterface do
  @moduledoc """
  Device's network interface
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SweetXml

  @required [:token, :enabled]

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:token, :string)
    field(:enabled, :boolean)

    embeds_one :info, Info, primary_key: false do
      @derive Jason.Encoder

      field(:name, :string)
      field(:hw_address, :string)
      field(:mtu, :integer)
    end

    embeds_one :link, Link, primary_key: false do
      @derive Jason.Encoder

      field(:interface_type, :integer)

      embeds_one :admin_settings, AdminSettings, primary_key: false do
        @derive Jason.Encoder

        field(:auto_negotiation, :boolean)
        field(:speed, :integer)
        field(:duplex, Ecto.Enum, values: [half: "Half", full: "Full"])
      end

      embeds_one :oper_settings, OperSettings, primary_key: false do
        @derive Jason.Encoder

        field(:auto_negotiation, :boolean)
        field(:speed, :integer)
        field(:duplex, Ecto.Enum, values: [half: "Half", full: "Full"])
      end
    end

    embeds_one :ipv4, IPv4, primary_key: false do
      @derive Jason.Encoder

      field(:enabled, :boolean)

      embeds_one :config, Config, primary_key: false do
        @derive Jason.Encoder

        field(:dhcp, :boolean)

        embeds_one :manual, Manual, primary_key: false do
          @derive Jason.Encoder

          field(:address, :string)
          field(:prefix_length, :integer)
        end

        embeds_one :link_local, LinkLocal, primary_key: false do
          @derive Jason.Encoder

          field(:address, :string)
          field(:prefix_length, :integer)
        end

        embeds_one :from_dhcp, FromDHCP, primary_key: false do
          @derive Jason.Encoder

          field(:address, :string)
          field(:prefix_length, :integer)
        end
      end
    end

    embeds_one :ipv6, IPv6, primary_key: false do
      @derive Jason.Encoder

      field(:enabled, :boolean)

      embeds_one :config, Config, primary_key: false do
        @derive Jason.Encoder

        field(:accept_router_advert, :boolean)

        field(:dhcp, Ecto.Enum,
          values: [auto: "Auto", stateful: "Stateful", stateless: "Stateless", off: "Off"]
        )

        embeds_one :manual, Manual, primary_key: false do
          @derive Jason.Encoder

          field(:address, :string)
          field(:prefix_length, :integer)
        end

        embeds_one :link_local, LinkLocal, primary_key: false do
          @derive Jason.Encoder

          field(:address, :string)
          field(:prefix_length, :integer)
        end

        embeds_one :from_dhcp, FromDHCP, primary_key: false do
          @derive Jason.Encoder

          field(:address, :string)
          field(:prefix_length, :integer)
        end

        embeds_one :from_ra, FromRA, primary_key: false do
          @derive Jason.Encoder

          field(:address, :string)
          field(:prefix_length, :integer)
        end
      end
    end
  end

  def parse(doc) do
    xmap(
      doc,
      token: ~x"./@token"s,
      enabled: ~x"./tt:Enabled/text()"s,
      info: ~x"./tt:Info"e |> transform_by(&parse_info/1),
      link: ~x"./tt:Link"e |> transform_by(&parse_link/1),
      ipv4: ~x"./tt:IPv4"e |> transform_by(&parse_ipv4/1),
      ipv6: ~x"./tt:IPv6"e |> transform_by(&parse_ipv6/1)
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

  defp parse_info(nil), do: nil

  defp parse_info(doc) do
    xmap(
      doc,
      name: ~x"./tt:Name/text()"s,
      hw_address: ~x"./tt:HwAddress/text()"s,
      mtu: ~x"./tt:MTU/text()"i
    )
  end

  defp parse_link(nil), do: nil

  defp parse_link(doc) do
    xmap(
      doc,
      interface_type: ~x"./tt:InterfaceType/text()"i,
      admin_settings: ~x"./tt:AdminSettings"e |> transform_by(&parse_connection_settings/1),
      oper_settings: ~x"./tt:OperSettings"e |> transform_by(&parse_connection_settings/1)
    )
  end

  defp parse_ipv4(nil), do: nil

  defp parse_ipv4(doc) do
    xmap(
      doc,
      enabled: ~x"./tt:Enabled/text()"s,
      config: ~x"./tt:Config"e |> transform_by(&parse_ipv4_config/1)
    )
  end

  defp parse_ipv6(nil), do: nil

  defp parse_ipv6(doc) do
    xmap(
      doc,
      enabled: ~x"./tt:Enabled/text()"s,
      config: ~x"./tt:Config"e |> transform_by(&parse_ipv6_config/1)
    )
  end

  defp parse_connection_settings(nil), do: nil

  defp parse_connection_settings(doc) do
    xmap(
      doc,
      auto_negotiation: ~x"./tt:AutoNegotiation/text()"s,
      speed: ~x"./tt:Speed/text()"i,
      duplex: ~x"./tt:Duplex/text()"s
    )
  end

  defp parse_ipv4_config(nil), do: nil

  defp parse_ipv4_config(doc) do
    xmap(
      doc,
      dhcp: ~x"./tt:DHCP/text()"s,
      manual: ~x"./tt:Manual"e |> transform_by(&parse_address/1),
      link_local: ~x"./tt:LinkLocal"e |> transform_by(&parse_address/1),
      from_dhcp: ~x"./tt:FromDHCP"e |> transform_by(&parse_address/1)
    )
  end

  defp parse_ipv6_config(nil), do: nil

  defp parse_ipv6_config(doc) do
    xmap(
      doc,
      accept_router_advert: ~x"./tt:AcceptRouterAdvert/text()"so,
      dhcp: ~x"./tt:DHCP/text()"s,
      manual: ~x"./tt:Manual"e |> transform_by(&parse_address/1),
      link_local: ~x"./tt:LinkLocal"e |> transform_by(&parse_address/1),
      from_dhcp: ~x"./tt:FromDHCP"e |> transform_by(&parse_address/1),
      from_ra: ~x"./tt:FromRA"e |> transform_by(&parse_address/1)
    )
  end

  defp parse_address(nil), do: nil

  defp parse_address(doc) do
    xmap(
      doc,
      address: ~x"./tt:Address/text()"s,
      prefix_length: ~x"./tt:PrefixLength/text()"i
    )
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, @required)
    |> cast_embed(:info, with: &info_changeset/2)
    |> cast_embed(:link, with: &link_changeset/2)
    |> cast_embed(:ipv4, with: &ipv4_changeset/2)
    |> cast_embed(:ipv6, with: &ipv6_changeset/2)
  end

  defp info_changeset(module, attrs) do
    cast(module, attrs, [:name, :hw_address, :mtu])
  end

  defp link_changeset(module, attrs) do
    module
    |> cast(attrs, [:interface_type])
    |> cast_embed(:admin_settings, with: &settings_changeset/2)
    |> cast_embed(:oper_settings, with: &settings_changeset/2)
  end

  defp settings_changeset(module, attrs) do
    cast(module, attrs, [:auto_negotiation, :speed, :duplex])
  end

  defp ipv4_changeset(module, attrs) do
    module
    |> cast(attrs, [:enabled])
    |> cast_embed(:config, with: &ipv4_config_changeset/2)
  end

  defp ipv4_config_changeset(module, attrs) do
    module
    |> cast(attrs, [:dhcp])
    |> cast_embed(:manual, with: &address_changeset/2)
    |> cast_embed(:link_local, with: &address_changeset/2)
    |> cast_embed(:from_dhcp, with: &address_changeset/2)
  end

  defp address_changeset(module, attrs) do
    cast(module, attrs, [:address, :prefix_length])
  end

  defp ipv6_changeset(module, attrs) do
    module
    |> cast(attrs, [:enabled])
    |> cast_embed(:config, with: &ipv6_config_changeset/2)
  end

  defp ipv6_config_changeset(module, attrs) do
    module
    |> cast(attrs, [:accept_router_advert, :dhcp])
    |> cast_embed(:manual, with: &address_changeset/2)
    |> cast_embed(:link_local, with: &address_changeset/2)
    |> cast_embed(:from_dhcp, with: &address_changeset/2)
    |> cast_embed(:from_ra, with: &address_changeset/2)
  end
end
