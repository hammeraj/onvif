defmodule Onvif.Media.Ver20.GetVideoEncoderConfigurations do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Device
  alias Onvif.Media.Ver20.Profile.VideoEncoder

  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver20/media/wsdl/GetVideoEncoderConfigurations"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args \\ []),
    do: Onvif.Media.Ver20.Media.request(device, args, __MODULE__)

  def request_body() do
    element(:"s:Body", [
      element(:"tr2:GetVideoEncoderConfigurations")
    ])
  end

  def request_body(configuration_token) do
    element(:"s:Body", [
      element(:"tr2:GetVideoEncoderConfigurations", [
        element(:"tr2:ConfigurationToken", configuration_token)
      ])
    ])
  end

  def request_body(configuration_token, profile_token) do
    element(:"s:Body", [
      element(:"tr2:GetVideoEncoderConfigurations", [
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
end
