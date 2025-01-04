defmodule Onvif.Media.Ver10.GetSnapshotUri do
  import SweetXml
  import XmlBuilder

  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetSnapshotUri"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  def request_body(profile_token) do
    element(:"s:Body", [
      element(:"trt:GetSnapshotUri", [element(:"trt:ProfileToken", profile_token)])
    ])
  end

  def response(xml_response_body) do
    doc = parse(xml_response_body, namespace_conformant: true, quiet: true)

    snapshot_uri =
      xpath(
        doc,
        ~x"//s:Envelope/s:Body/trt:GetSnapshotUriResponse/trt:MediaUri/tt:Uri/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )

    {:ok, snapshot_uri}
  end
end
