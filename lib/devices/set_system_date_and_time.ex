defmodule Onvif.Devices.SetSystemDateAndTime do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Devices.SystemDateAndTime

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/SetSystemDateAndTime"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args) do
    Onvif.Devices.request(device, args, __MODULE__)
  end

  def request_body([config: %SystemDateAndTime{} = system_date_time] = opts) do
    request_body([config: system_date_time, set_time?: false])
  end

  def request_body([config: %SystemDateAndTime{} = system_date_time, set_time?: set_time?] = opts) do
    element(:"s:Body", [
      element(:"tds:SetSystemDateAndTime", [
        element(:"tds:DateAndTime", system_date_time.date_time_type),
        element(:"tds:DaylightSavings", system_date_time.daylight_savings),
        element(
          :"tds:TimeZone",
          [
            element(:"tt:TZ", system_date_time.time_zone.tz)
          ]
        ),
        List.flatten([utc_date_time_element(system_date_time, set_time?)])
      ])
    ])
  end

  def utc_date_time_element(_system_date_time, false), do: []

  def utc_date_time_element(system_date_time, true) do
    element(
      :"tds:UTCDateTime",
      [
        element(:"tt:Time", [
          element(:"tt:Hour", system_date_time.utc_date_time.time.hour),
          element(:"tt:Minute", system_date_time.utc_date_time.time.minute),
          element(:"tt:Second", system_date_time.utc_date_time.time.second)
        ]),
        element(:"tt:Date", [
          element(:"tt:Year", system_date_time.utc_date_time.date.year),
          element(:"tt:Month", system_date_time.utc_date_time.date.month),
          element(:"tt:Day", system_date_time.utc_date_time.date.day)
        ])
      ]
    )
  end

  def response(xml_response_body) do
    res =
      xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tds:SetSystemDateAndTimeResponse/text()"s
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tds", "http://www.onvif.org/ver10/device/wsdl")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )

    {:ok, res}
  end
end
