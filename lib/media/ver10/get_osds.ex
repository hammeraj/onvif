defmodule Onvif.Media.Ver10.GetOSDs do
  import SweetXml
  import XmlBuilder
  require Logger

  alias Onvif.Media.Ver10.OSD

  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetOSDs"

  def request(device),
  do: Onvif.Media.Ver10.Media.request(device, __MODULE__)

  def request(device, args),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  def request_body() do
    element(:"s:Body", [
      element(:"trt:GetOSDs")
    ])
  end

  def request_body(video_source_token) do
    element(:"s:Body", [
      element(:"trt:GetOSDs", [
        element(:"trt:ConfigurationToken", video_source_token)
      ])
    ])
  end

  @spec response(any) :: {:error, Ecto.Changeset.t()} | {:ok, struct()}
  def response(xml_response_body) do
    response =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trt:GetOSDsResponse/trt:OSDs"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Enum.map(&OSD.parse/1)
      |> Enum.reduce([], fn raw_osd, acc ->
        case OSD.to_struct(raw_osd) do
          {:ok, osd} ->
            [osd | acc]

          {:error, changeset} ->
            Logger.error("Discarding invalid service: #{inspect(changeset)}")
            acc
        end
      end)
    {:ok, response}
  end
end
