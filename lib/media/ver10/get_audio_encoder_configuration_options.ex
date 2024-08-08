defmodule Onvif.Media.Ver10.GetAudioEncoderConfigurationOptions do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device


  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/GetAudioEncoderConfigurationOptions"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  def request_body(configuration_token, profile_token) do
    element(:"s:Body", [
      element(:"trt:GetAudioEncoderConfigurationOptions", [
        gen_config_token_element(configuration_token),
        gen_profile_token_element(profile_token),
      ])
    ])
  end

  def gen_profile_token_element(nil), do: []
  def gen_profile_token_element(profile_token) do
    element(:"trt:ProfileToken", profile_token)
  end

  def gen_config_token_element(nil), do: []
  def gen_config_token_element(configuration_token) do
    element(:"trt:ConfigurationToken", configuration_token)
  end

  @spec response(any) :: {:error, Ecto.Changeset.t()} | {:ok, struct()}
  def response(xml_response_body) do
    IO.inspect xml_response_body
  end
end
