defmodule Onvif.PTZ.GetNodes do
  @moduledoc """
  Get the descriptions of the available PTZ Nodes.

  A PTZ-capable device may have multiple PTZ Nodes. The PTZ Nodes may represent mechanical PTZ drivers, uploaded PTZ drivers or digital PTZ drivers.
  PTZ Nodes are the lowest level entities in the PTZ control API and reflect the supported PTZ capabilities.

  The PTZ Node is referenced either by its name or by its reference token.
  """

  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.PTZ.Schemas.PTZNode

  def soap_action(), do: "http://www.onvif.org/ver20/ptz/wsdl/GetNodes"

  @spec request(Device.t()) :: {:ok, [PTZNode.t()]} | {:error, map()}
  def request(device), do: Onvif.PTZ.request(device, __MODULE__)

  def request_body(), do: element(:"s:Body", [:"tptz:GetNodes"])

  def response(xml_response_body) do
    response =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tptz:GetNodesResponse/tptz:PTZNode"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
        |> add_namespace("tptz", "http://www.onvif.org/ver20/ptz/wsdl")
      )
      |> Enum.map(&Onvif.PTZ.Schemas.PTZNode.parse/1)
      |> Enum.reduce([], fn raw_ptz_node, acc ->
        case Onvif.PTZ.Schemas.PTZNode.to_struct(raw_ptz_node) do
          {:ok, ptz_node} ->
            [ptz_node | acc]

          {:error, changeset} ->
            Logger.error("Discarding invalid PTZ node: #{inspect(changeset)}")
            acc
        end
      end)

    {:ok, Enum.reverse(response)}
  end
end
