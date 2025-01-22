defmodule Onvif.Media.Ver10.GetServiceCapabilities do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetServiceCapabilities"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device),
    do: Onvif.Media.Ver10.Media.request(device, [], __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"trt:GetServiceCapabilities")])
  end

  def response(xml_response_body) do
    parsed =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trt:GetServiceCapabilitiesResponse/trt:Capabilities"e
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Onvif.Media.Ver10.Schemas.ServiceCapabilities.parse()
      |> Onvif.Media.Ver10.Schemas.ServiceCapabilities.to_struct()

    response =
      case parsed do
        {:ok, sevice} ->
          sevice

        {:error, changeset} ->
          Logger.error("Discarding invalid service capability: #{inspect(changeset)}")
          %Onvif.Media.Ver10.Schemas.ServiceCapabilities{}
      end

    {:ok, response}
  end
end
