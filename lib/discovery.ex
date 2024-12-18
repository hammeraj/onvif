defmodule Onvif.Discovery do
  @moduledoc """
    Module for discovering devices on a local network via WS Discovery protocol
  """

  import XmlBuilder
  import SweetXml
  require Logger

  @namespaces [
    "xmlns:s": "http://www.w3.org/2003/05/soap-envelope",
    "xmlns:tds": "http://www.onvif.org/ver10/device/wsdl",
    "xmlns:sc": "http://www.w3.org/2003/05/soap-encoding",
    "xmlns:dn": "http://www.onvif.org/ver10/network/wsdl",
    "xmlns:d": "http://schemas.xmlsoap.org/ws/2005/04/discovery",
    "xmlns:a": "http://schemas.xmlsoap.org/ws/2004/08/addressing"
  ]

  @probe_type "dn:NetworkVideoTransmitter tds:Device"
  @probe_timeout_msec :timer.seconds(2)
  @onvif_discovery_ip {239, 255, 255, 250}
  @onvif_discovery_port 3702
  @onvif_scope_prefix "onvif://www.onvif.org/"

  defmodule Probe do
    @type t :: %__MODULE__{}
    @derive Jason.Encoder
    defstruct [:types, :scopes, :request_guid, :address, :device_ip, :device_port]
  end

  @doc """
  Returns a list of `Probe.t()` that have responded via a UDP multicast call
  on the local network. Devices on subnets / attached routers won't respond.

  Duplicate probes may be returned and it is up to the calling application to
  choose how to filter out a duplicate.

  `opts` are a keyword list of options,
  - `:probe_timeout` denotes how long the probe will wait between new probe responses before closing out the
  listener. There currently is no forced duration so if the network continuously
  generates probe messages this has the possibility to hang.
  - `:multicast_loop` defaults to false. Enabling it will allow host to echoing the multicast packets back to itself.
  This is useful when this library runs in same device where you simulate a ONVIF device (https://www.happytimesoft.com/products/onvif-server/index.html)
  - `:ip_address` If the local host has many IP addresses, this option specifies which one to use.
  """
  @spec probe(Keyword.t()) :: list(Probe.t())
  def probe(opts \\ [probe_timeout: @probe_timeout_msec, multicast_loop: false]) do
    payload = probe_payload()
    multicast_loop = Keyword.get(opts, :multicast_loop, false)

    socket_options =
      [mode: :binary, active: true, multicast_loop: multicast_loop]
      |> set_ip_address(Keyword.get(opts, :ip_address))

    {:ok, socket} = :gen_udp.open(0, socket_options)
    :gen_udp.send(socket, @onvif_discovery_ip, @onvif_discovery_port, payload)
    receive_message(socket, opts, [])
  end

  @doc """
  Returns a single `Probe.t()` or an error based on filter criteria provided.

  Duplicate matches to the criteria will only return the first probe that responded
  to the UDP multicast message. As this uses `probe/0` under the hood it is subject to
  the same limitations and the default probe timeout.

    `filter` can be a keyword list containing one of:

    `serial` - device serial number, not guaranteed to be present

    `ip_address` - device ip that responded to the onvif multicast

    `mac_address` - device mac address, not guaranteed to be present. Accepts colon separated, dash separated, and only digits

    `name` - device name, usually the model number or something manufacturer determined

    `filter` can also be:

    an onvif scope - `"onvif://www.onvif.org/scope_name/scope_value"`, not guaranteed to be present

    a list of onvif scopes - matches the first one to succeed linking to a probe
  """
  @spec probe_by(Keyword.t() | String.t() | list(String.t())) ::
          {:error, :invalid_filter | :invalid_mac | :not_found} | {:ok, Probe.t()}
  def probe_by(serial: serial) when is_binary(serial) do
    probe_by(@onvif_scope_prefix <> "serial/" <> serial)
  end

  def probe_by(ip_address: ip_address) when is_binary(ip_address) do
    probe()
    |> filter_probe_by_key(:device_ip, ip_address)
    |> case do
      nil -> {:error, :not_found}
      probe -> {:ok, probe}
    end
  end

  def probe_by(mac_address: mac_address) when is_binary(mac_address) do
    with {:ok, mac_with_colons} <- Onvif.MacAddress.mac_with_colons(mac_address),
         {:ok, mac_just_digits} <- Onvif.MacAddress.mac_just_digits(mac_address) do
      probe_by([
        @onvif_scope_prefix <> "macaddr/" <> mac_just_digits,
        @onvif_scope_prefix <> "MAC/" <> mac_with_colons
      ])
    end
  end

  def probe_by(name: name) when is_binary(name) do
    probe_by(@onvif_scope_prefix <> "name/" <> name)
  end

  def probe_by(scopes) when is_list(scopes) do
    probe_results = probe()

    scopes
    |> Enum.reduce_while(nil, fn scope, _acc ->
      case filter_probe_by_scope(probe_results, scope) do
        nil -> {:cont, nil}
        probe -> {:halt, probe}
      end
    end)
    |> case do
      nil -> {:error, :not_found}
      probe -> {:ok, probe}
    end
  end

  def probe_by(scope) when is_binary(scope) do
    probe()
    |> filter_probe_by_scope(scope)
    |> case do
      nil -> {:error, :not_found}
      probe -> {:ok, probe}
    end
  end

  def probe_by(_filter), do: {:error, :invalid_filter}

  defp filter_probe_by_scope(probes, scope) do
    Enum.find(probes, fn probe ->
      Enum.member?(probe.scopes, scope)
    end)
  end

  defp filter_probe_by_key(probes, key, value) do
    Enum.find(probes, fn probe ->
      Map.get(probe, key) == value
    end)
  end

  defp receive_message(socket, opts, acc) do
    timeout = Keyword.get(opts, :probe_timeout, @probe_timeout_msec)

    receive do
      {:udp, _port, device_ip, device_port, udp_response} ->
        valid_probes =
          case parse_udp_xml_response(udp_response) do
            {:ok, probe_response} ->
              string_device_ip = device_ip |> :inet.ntoa() |> List.to_string()

              [
                %Probe{probe_response | device_ip: string_device_ip, device_port: device_port}
                | acc
              ]

            error ->
              Logger.debug(inspect(error))
              acc
          end

        receive_message(socket, opts, valid_probes)
    after
      timeout ->
        Logger.debug("Closing socket after not receiving anything for #{@probe_timeout_msec} ms")
        :gen_udp.close(socket)
        acc
    end
  end

  defp probe_payload do
    uuid = Ecto.UUID.generate()
    content = element(:"d:Probe", [element(:"d:Types", @probe_type)])

    envelope([header(uuid), body(content)])
  end

  defp body([_ | _] = content) do
    element(:"s:Body", content)
  end

  defp body(content), do: body([content])

  defp header(uuid) do
    element(:"s:Header", [
      element(:"a:MessageID", "uuid:#{uuid}"),
      element(
        :"a:ReplyTo",
        [element(:"a:Address", "http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous")]
      ),
      element(:"a:To", "urn:schemas-xmlsoap-org:ws:2005:04:discovery"),
      element(:"a:Action", "http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe")
    ])
  end

  defp envelope(body) do
    generate(element(:"s:Envelope", @namespaces, body))
  end

  defp parse_udp_xml_response(udp_xml_response) do
    parsed_xml_response = parse(udp_xml_response, namespace_conformant: true)

    case parse_request_guid(parsed_xml_response) do
      request_guid when request_guid in [nil, ""] ->
        {:error, {:bad_probe, udp_xml_response}}

      request_guid ->
        created_probe =
          parsed_xml_response |> parse_discovery_attrs() |> create_probe(request_guid)

        {:ok, created_probe}
    end
  end

  defp parse_request_guid(parsed_response) do
    parsed_response
    |> xpath(
      add_namespace(~x"//s:Envelope/s:Header"e, "s", "http://www.w3.org/2003/05/soap-envelope")
    )
    |> case do
      nil ->
        nil

      header_xml ->
        xpath(
          header_xml,
          ~x"./wsa:RelatesTo/text()"s
          |> add_namespace("wsa", "http://schemas.xmlsoap.org/ws/2004/08/addressing")
          |> transform_by(&String.replace_leading(&1, "uuid:", ""))
        )
    end
  end

  defp parse_discovery_attrs(parsed_response) do
    body =
      xpath(
        parsed_response,
        add_namespace(
          ~x"//s:Envelope/s:Body"e,
          "s",
          "http://www.w3.org/2003/05/soap-envelope"
        )
      )

    xpath(
      body,
      ~x"./tns:ProbeMatches/tns:ProbeMatch"
      |> add_namespace("tns", "http://schemas.xmlsoap.org/ws/2005/04/discovery"),
      types:
        ~x"./tns:Types/text()"s
        |> add_namespace("tns", "http://schemas.xmlsoap.org/ws/2005/04/discovery")
        |> transform_by(&String.split/1),
      scopes:
        ~x"./tns:Scopes/text()"s
        |> add_namespace("tns", "http://schemas.xmlsoap.org/ws/2005/04/discovery")
        |> transform_by(&String.split/1),
      address:
        ~x"./tns:XAddrs/text()"s
        |> add_namespace("tns", "http://schemas.xmlsoap.org/ws/2005/04/discovery")
        |> transform_by(&String.split/1)
    )
  end

  defp create_probe(discovery_attrs, request_guid) do
    %Probe{}
    |> Map.merge(discovery_attrs)
    |> Map.put(:request_guid, request_guid)
  end

  defp set_ip_address(opts, nil), do: opts

  defp set_ip_address(opts, addr) when is_binary(addr) do
    case :inet.parse_address(to_charlist(addr)) do
      {:ok, addr} -> Keyword.put(opts, :ip, addr)
      _error -> opts
    end
  end

  defp set_ip_address(opts, addr), do: Keyword.put(opts, :ip, addr)
end
