defmodule Onvif.Media.Ver10.GetVideoSources do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device

  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetVideoSources"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device),
    do: Onvif.Media.Ver10.Media.request(device, __MODULE__)

  def request_body() do
    element(:"s:Body", [
      element(:"tds:GetVideoSources")
    ])
  end

  @spec response(any) :: {:error, Ecto.Changeset.t()} | {:ok, struct()}
  def response(xml_response_body) do
    xml_response_body
  end
end
