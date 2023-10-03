defmodule Onvif.Media.Ver10.GetProfiles do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetProfiles"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device),
    do: Onvif.Media.Ver10.Media.request(device, [], __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"trt:GetProfiles")])
  end

  @doc """
  Parses the device response into a `{:ok, profiles}` tuple where `profiles`
  is a list, discarding the invalid transformations from map into a
  Onvif.Media.Ver10.Profile.t().
  """
  def response(xml_response_body) do
    response =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trt:GetProfilesResponse/trt:Profiles"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Enum.map(&Onvif.Media.Ver10.Profile.parse/1)
      |> Enum.reduce([], fn raw_profile, acc ->
        case Onvif.Media.Ver10.Profile.to_struct(raw_profile) do
          {:ok, profile} ->
            [profile | acc]

          {:error, changeset} ->
            Logger.error("Discarding invalid profile: #{inspect(changeset)}")
            acc
        end
      end)

    {:ok, response}
  end
end
