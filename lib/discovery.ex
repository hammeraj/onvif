defmodule Onvif.Discovery do
  @moduledoc """
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

  @probe_type "tds:NetworkVideoTransmitter"
  @probe_timeout_msec :timer.seconds(2)
  @onvif_discovery_ip {239, 255, 255, 250}
  @onvif_discovery_port 3702

  defmodule Probe do
    @type t :: %__MODULE__{}
    defstruct [:types, :scopes, :request_guid, :address, :device_ip, :device_port]
  end

  @spec probe() :: list(Probe.t())
  def probe do
    payload = probe_payload()
    {:ok, socket} = :gen_udp.open(0, mode: :binary, active: true, multicast_loop: false)
    :gen_udp.send(socket, @onvif_discovery_ip, @onvif_discovery_port, payload)

    socket
    |> receive_message([])
    |> Enum.group_by(&(&1.address))
    |> Enum.reduce([], fn {k, v} , acc -> [Enum.at(v, 0) | acc] end)
  end

  defp receive_message(socket, acc) do
    receive do
      {:udp, _port, device_ip, device_port, udp_response} ->
        probe_response = parse_udp_xml_response(udp_response)
        string_device_ip = device_ip |> :inet.ntoa() |> List.to_string()

        probe = %Probe{probe_response | device_ip: string_device_ip, device_port: device_port}

        receive_message(socket, [probe | acc])
    after
      @probe_timeout_msec ->
        Logger.debug("Closing socket after not receiving anything for #{@probe_timeout_msec} ms")
        :gen_udp.close(socket)
        acc
    end
  end

  defp probe_payload do
    uuid = UUID.uuid4()
    content = element(:"d:Probe", [element(:"d.Types", @probe_type)])

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

    header =
      xpath(
        parsed_xml_response,
        add_namespace(~x"//s:Envelope/s:Header"e, "s", "http://www.w3.org/2003/05/soap-envelope")
      )

    body =
      xpath(
        parsed_xml_response,
        add_namespace(~x"//s:Envelope/s:Body"e, "s", "http://www.w3.org/2003/05/soap-envelope")
      )

    request_guid =
      xpath(
        header,
        ~x"./wsa:RelatesTo/text()"s
        |> add_namespace("wsa", "http://schemas.xmlsoap.org/ws/2004/08/addressing")
        |> transform_by(&String.replace_leading(&1, "uuid:", ""))
      )

    discovery_attrs =
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

    %Probe{}
    |> Map.merge(discovery_attrs)
    |> Map.put(:request_guid, request_guid)
  end
end
