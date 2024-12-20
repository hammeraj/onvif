defmodule Onvif.Media.Ver10.GetVideoEncoderConfigurationOptions do
  import SweetXml
  import XmlBuilder

  require Logger

  alias Onvif.Device
  alias Onvif.Media.Ver10.Profile.VideoEncoderConfigurationOption

  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetVideoEncoderConfigurationOptions"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args \\ []),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  def request_body() do
    element(:"s:Body", [
      element(:"trt:GetVideoEncoderConfigurationOptions")
    ])
  end

  def request_body(configuration_token) do
    element(:"s:Body", [
      element(:"trt:GetVideoEncoderConfigurationOptions", [
        element(:"trt:ConfigurationToken", configuration_token)
      ])
    ])
  end

  def request_body(configuration_token, profile_token) do
    element(:"s:Body", [
      element(:"trt:GetVideoEncoderConfigurationOptions", [
        element(:"trt:ConfigurationToken", configuration_token),
        element(:"trt:ProfileToken", profile_token)
      ])
    ])
  end

  @spec response(any) :: {:error, Ecto.Changeset.t()} | {:ok, struct()}
  def response(xml_response_body) do
    response =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trt:GetVideoEncoderConfigurationOptionsResponse/trt:Options"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Enum.map(&VideoEncoderConfigurationOption.parse/1)
      |> Enum.reduce([], fn raw_config, acc ->
        case VideoEncoderConfigurationOption.to_struct(raw_config) do
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
