defmodule Onvif.Media.Ver10.SetOSD do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Media.Ver10.Schemas.OSD
  alias Onvif.Media.Ver10.Schemas.OSD.Image
  alias Onvif.Media.Ver10.Schemas.OSD.TextString.BackgroundColor
  alias Onvif.Media.Ver10.Schemas.OSD.TextString.FontColor

  @spec soap_action :: String.t()
  def soap_action, do: "http://www.onvif.org/ver10/media/wsdl/SetOSD"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args),
    do: Onvif.Media.Ver10.Media.request(device, args, __MODULE__)

  def request_body(%OSD{} = osd) do
    element(:"s:Body", [
      element(:"trt:SetOSD", [
        element(:"trt:OSD", %{token: osd.token}, [
          element(:"tt:VideoSourceConfigurationToken", osd.video_source_configuration_token),
          element(
            :"tt:Type",
            Keyword.fetch!(Ecto.Enum.mappings(osd.__struct__, :type), osd.type)
          ),
          element(:"tt:Position", [
            element(
              :"tt:Type",
              Keyword.fetch!(
                Ecto.Enum.mappings(osd.position.__struct__, :type),
                osd.position.type
              )
            ),
            element(:"tt:Pos", %{x: osd.position.pos.x, y: osd.position.pos.y})
          ]),
          gen_element_type(osd.type, osd)
        ])
      ])
    ])
  end

  defp gen_element_type(:text, osd) do
    element(
      :"tt:TextString",
      [
        element_is_persistent_text(osd.text_string.is_persistent_text),
        element(
          :"tt:Type",
          Keyword.fetch!(
            Ecto.Enum.mappings(osd.text_string.__struct__, :type),
            osd.text_string.type
          )
        ),
        element_font_size(osd.text_string.font_size),
        font_color_element(osd.text_string.font_color),
        background_color_element(osd.text_string.background_color)
      ] ++ gen_text_type(osd.text_string.type, osd)
    )
  end

  defp gen_element_type(:image, osd) do
    image_element(osd.image)
  end

  defp gen_text_type(:plain, osd) do
    [element_plain_text(osd.text_string.plain_text)]
  end

  defp gen_text_type(:date, osd) do
    [element_date_format(osd.text_string.date_format)]
  end

  defp gen_text_type(:time, osd) do
    [element_time_format(osd.text_string.time_format)]
  end

  defp gen_text_type(:date_and_time, osd) do
    [
      element_date_format(osd.text_string.date_format),
      element_time_format(osd.text_string.time_format)
    ]
  end

  defp element_is_persistent_text(nil), do: []

  defp element_is_persistent_text(is_persistent_text) do
    element(:"tt:IsPersistentText", is_persistent_text)
  end

  defp element_date_format(nil), do: []

  defp element_date_format(date_format) do
    element(:"tt:DateFormat", date_format)
  end

  defp element_time_format(nil), do: []

  defp element_time_format(time_format) do
    element(:"tt:TimeFormat", time_format)
  end

  defp element_font_size(nil), do: []

  defp element_font_size(font_size) do
    element(:"tt:FontSize", font_size)
  end

  defp element_plain_text(nil), do: []

  defp element_plain_text(plain_text) do
    element(:"tt:PlainText", plain_text)
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
        ~x"//s:Envelope/s:Body/trt:SetOSDResponse/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("trt", "http://www.onvif.org/ver10/media/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )

    {:ok, res}
  end
end
