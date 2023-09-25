defmodule Onvif.Media.Ver10.GetProfile do
  require Logger

  import SweetXml
  import XmlBuilder

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetProfiles"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  def request_body(profile_token) do
    element(:"s:Body", [element(:"trt:GetProfile", [element(:"trt:ProfileToken", profile_token)])])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/tr2:GetProfilesResponse/tr2:Profiles"el
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
      |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
    )
    |> Onvif.Media.Ver10.Profile.parse()
    |> Onvif.Media.Ver10.Profile.to_struct()
    |> case do
      {:ok, data} -> data
      {:error, _changeset} -> Logger.error("Error in validating #{__MODULE__} changeset")
    end
  end
end
