defmodule Onvif.PTZ.GetStatus do
  @moduledoc """
  Operation to request PTZ status for the Node in the selected profile.
  """

  import SweetXml
  import XmlBuilder

  require Logger

  def soap_action(), do: "http://www.onvif.org/ver20/ptz/wsdl/GetStatus"

  @spec request(Device.t(), String.t()) :: {:ok, any()} | {:error, map()}
  def request(device, args), do: Onvif.PTZ.request(device, args, __MODULE__)

  def request_body(profile_token) do
    element(:"s:Body", [
      element(:"tptz:GetStatus", [element(:"tptz:ProfileToken", profile_token)])
    ])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/tptz:GetStatusResponse/tptz:PTZStatus"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      |> add_namespace("tptz", "http://www.onvif.org/ver20/ptz/wsdl")
    )
    |> Onvif.PTZ.Schemas.PTZStatus.parse()
    |> Onvif.PTZ.Schemas.PTZStatus.to_struct()
  end
end
