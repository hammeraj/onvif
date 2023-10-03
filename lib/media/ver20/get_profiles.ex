defmodule Onvif.Media.Ver20.GetProfiles do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Device

  def soap_action, do: "http://www.onvif.org/ver20/media/wsdl/GetProfiles"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args \\ []),
    do: Onvif.Media.Ver20.Media.request(device, args, __MODULE__)

  def request_body(profile_token) do
    element(:"s:Body", [
      element(:"tr2:GetProfiles", [
        element(:"tr2:Token", profile_token),
        element(:"tr2:Type", "All")
      ])
    ])
  end

  def request_body do
    element(:"s:Body", [element(:"tr2:GetProfiles", [element(:"tr2:Type", "All")])])
  end

  @doc """
  Parses the device response into a `{:ok, profiles}` tuple where `profiles`
  is a list, discarding the invalid transformations from map into a
  Onvif.Media.Ver20.Profile.t().
  """
  def response(xml_response_body) do
    response =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tr2:GetProfilesResponse/tr2:Profiles"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tr2", "http://www.onvif.org/ver20/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Enum.map(&Onvif.Media.Ver20.Profile.parse/1)
      |> Enum.reduce([], fn raw_profile, acc ->
        case Onvif.Media.Ver20.Profile.to_struct(raw_profile) do
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
