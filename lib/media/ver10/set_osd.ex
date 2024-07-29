defmodule Onvif.Media.Ver10.SetOSD do
  import SweetXml
  import XmlBuilder

  alias Onvif.Media.Ver10.OSD.TextString.FontColor
  alias Onvif.Media.Ver10.OSD.TextString.BackgroundColor
  alias Onvif.Media.Ver10.OSD.Image
  alias Onvif.Device
  alias Onvif.Media.Ver10.OSD

  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/SetOSD"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  def request_body(%OSD{} = osd) do
    element(:"s:Body", [
      element(:"trt:SetOSD", [
        element(:"tt:OSD", %{token: osd.token}, [
          element(:"tt:VideoSourceConfigurationToken", osd.video_source_configuration_token),
          element(:"tt:Type", osd.type),
          element(:"tt:Position", [
            element(:"tt:Type", osd.position.type),
            element(:"tt:Pos", %{x: osd.position.pos.x, y: osd.position.pos.y})
          ]),
          element(:"tt:TextString", [
            element(:"tt:IsPersistentText", osd.text_string.is_persistent_text),
            element(:"tt:Type", osd.text_string.type),
            element(:"tt:DateFormat", osd.text_string.date_format),
            element(:"tt:TimeFormat", osd.text_string.time_format),
            element(:"tt:FontSize", osd.text_string.font_size),
            font_color_element(osd.text_string.font_color),
            background_color_element(osd.text_string.background_color),
            element(:"tt:PlainText", osd.text_string.plain_text)
          ]),
          image_element(osd.image)
        ])
      ])
    ])
  end

  defp font_color_element(nil), do: []

  defp font_color_element(%FontColor{} = font_color) do
    element(:"tt:FontColor", [
      element(:"tt:Color", %{
        X: font_color.color.x,
        Y: font_color.color.y,
        Z: font_color.color.z,
        Colorspace: font_color.color.colorspace
      })
    ])
  end

  defp background_color_element(nil), do: []

  defp background_color_element(%BackgroundColor{} = background_color) do
    element(:BackgroundColor, [
      element(:"tt:Color", %{
        X: background_color.color.x,
        Y: background_color.color.y,
        Z: background_color.color.z,
        Colorspace: background_color.color.colorspace
      })
    ])
  end

  defp image_element(nil), do: []

  defp image_element(%Image{} = image) do
    element(:"tt:Image", [
      element(:"tt:ImagePath", image.image_path)
    ])
  end

  def response(xml_response_body) do
    res =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/trt:GetOSDResponse/trt:OSD"e
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )

    {:ok, res}
  end
end
