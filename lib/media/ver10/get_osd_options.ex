defmodule Onvif.Media.Ver10.GetOSDOptions do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Media.Ver10.OSDOptions

  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetOSDOptions"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  def request_body(token) do
    element(:"s:Body", [
      element(:"trt:GetOSDOptions", [
        element(:"tt:ConfigurationToken", token)
      ])
    ])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/trt:GetOSDResponse/trt:OSD"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
    )
    |> OSDOptions.parse()
    |> OSDOptions.to_struct()
  end
end
