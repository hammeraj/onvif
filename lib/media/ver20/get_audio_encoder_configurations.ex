defmodule Onvif.Media.Ver20.GetAudioEncoderConfigurations do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Device
  alias Onvif.Media.Ver10.Profile.AudioEncoderConfiguration

  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver20/media/wsdl/GetAudioEncoderConfigurations"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args \\ []),
    do: Onvif.Media.Ver20.Media.request(device, args, __MODULE__)

  def request_body() do
    element(:"s:Body", [
      element(:"tr2:GetAudioEncoderConfigurations")
    ])
  end

  def request_body(configuration_token) do
    element(:"s:Body", [
      element(:"tr2:GetAudioEncoderConfigurations", [
        element(:"tr2:ConfigurationToken", configuration_token)
      ])
    ])
  end

  def request_body(configuration_token, profile_token) do
    element(:"s:Body", [
      element(:"tr2:GetAudioEncoderConfigurations", [
        element(:"tr2:ConfigurationToken", configuration_token),
        element(:"tr2:ProfileToken", profile_token)
      ])
    ])
  end

  @spec response(any) :: {:error, Ecto.Changeset.t()} | {:ok, struct()}
  def response(xml_response_body) do
    response =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tr2:GetAudioEncoderConfigurationsResponse/tr2:Configurations"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tr2", "http://www.onvif.org/ver20/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver20/schema")
      )
      |> Enum.map(&AudioEncoderConfiguration.parse/1)
      |> Enum.reduce([], fn raw_config, acc ->
        case AudioEncoderConfiguration.to_struct(raw_config) do
          {:ok, config} ->
            [config | acc]

          {:error, changeset} ->
            Logger.error("Discarding invalid audio config: #{inspect(changeset)}")
            acc
        end
      end)

    {:ok, response}
  end
end
