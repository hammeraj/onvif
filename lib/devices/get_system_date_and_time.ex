defmodule Onvif.Devices.GetSystemDateAndTime do
  import SweetXml
  import XmlBuilder

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/GetSystemDateAndTime"

  def request(uri), do: Onvif.Devices.request(uri, :no_auth, __MODULE__)

  def request_body do
    element(:"s:Body", [element(:"tds:GetSystemDateAndTime")])
  end

  def response(xml_response_body) do
    doc = parse(xml_response_body, namespace_conformant: true, quiet: true)

    parsed_result =
      xpath(
        doc,
        ~x"//s:Envelope/s:Body/tds:GetSystemDateAndTimeResponse/tds:SystemDateAndTime"
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl"),
        hour:
          ~x"./tt:UTCDateTime/tt:Time/tt:Hour/text()"i
          |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
        minute:
          ~x"./tt:UTCDateTime/tt:Time/tt:Minute/text()"i
          |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
        second:
          ~x"./tt:UTCDateTime/tt:Time/tt:Second/text()"i
          |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
        year:
          ~x"./tt:UTCDateTime/tt:Date/tt:Year/text()"i
          |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
        month:
          ~x"./tt:UTCDateTime/tt:Date/tt:Month/text()"i
          |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
        day:
          ~x"./tt:UTCDateTime/tt:Date/tt:Day/text()"i
          |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
        timezone:
          ~x"./tt:Timezone/tt:TZ/text()"s
          |> add_namespace("tt", "http://www.onvif.org/ver10/schema"),
        ntp:
          ~x"./tt:DateTimeType/text()"s
          |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )

    current = DateTime.utc_now()
    {:ok, date} = Date.new(parsed_result.year, parsed_result.month, parsed_result.day)
    {:ok, time} = Time.new(parsed_result.hour, parsed_result.minute, parsed_result.second)
    {:ok, datetime} = DateTime.new(date, time)
    diff_between_device = DateTime.diff(datetime, current)

    {:ok,
     %Onvif.Devices.SystemDateAndTime{
       datetime: datetime,
       ntp: parsed_result.ntp,
       current_diff: diff_between_device
     }}
  end
end
