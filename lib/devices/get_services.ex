defmodule Onvif.Devices.GetServices do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Device
  alias Onvif.Devices.Schemas.Service

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetServices"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device), do: Onvif.Devices.request(device, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tds:GetServices", [element(:"tds:IncludeCapability", "true")])])
  end

  @doc """
  Parses the device response into a `{:ok, services}` tuple where `services`
  is a list, discarding the invalid transformations from map into a
  Onvif.Devices.Schemas.Service.t().
  """
  def response(xml_response_body) do
    result =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tds:GetServicesResponse/tds:Service"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Enum.map(&Service.parse/1)
      |> Enum.reduce([], fn raw_service, acc ->
        case Service.to_struct(raw_service) do
          {:ok, service} ->
            [service | acc]

          {:error, changeset} ->
            Logger.error("Discarding invalid service: #{inspect(changeset)}")
            acc
        end
      end)

    {:ok, result}
  end
end
