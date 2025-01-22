defmodule Onvif.Media.Ver20.GetVideoEncoderConfigurations do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Device
  alias Onvif.Media.Ver20.Schemas.Profile.VideoEncoder

  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver20/media/wsdl/GetVideoEncoderConfigurations"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args \\ []),
    do: Onvif.Media.Ver20.Media.request(device, args, __MODULE__)

  def request_body(configuration_token \\ nil, profile_token \\ nil) do
    config =
      [] |> with_configuration_token(configuration_token) |> with_profile_token(profile_token)

    element(:"s:Body", [
      element(:"tr2:GetVideoEncoderConfigurations", config)
    ])
  end

  @spec response(any) :: {:error, Ecto.Changeset.t()} | {:ok, struct()}
  def response(xml_response_body) do
    response =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tr2:GetVideoEncoderConfigurationsResponse/tr2:Configurations"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tr2", "http://www.onvif.org/ver20/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver20/schema")
      )
      |> Enum.map(&VideoEncoder.parse/1)
      |> Enum.reduce([], fn raw_config, acc ->
        case VideoEncoder.to_struct(raw_config) do
          {:ok, config} ->
            [config | acc]

          {:error, changeset} ->
            Logger.error("Discarding invalid Video config: #{inspect(changeset)}")
            acc
        end
      end)

    {:ok, response}
  end

  defp with_configuration_token(config, nil), do: config

  defp with_configuration_token(config, configuration_token) do
    [element(:"tr2:ConfigurationToken", configuration_token) | config]
  end

  defp with_profile_token(config, nil), do: config

  defp with_profile_token(config, profile_token) do
    [element(:"tr2:ProfileToken", profile_token) | config]
  end
end
