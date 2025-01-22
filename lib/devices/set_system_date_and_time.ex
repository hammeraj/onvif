defmodule Onvif.Devices.SetSystemDateAndTime do
  @moduledoc """
    Module used to set the device system date and time as well as their configuration such as daylight saving and NTP or Manual update type on an ONVIF device.
    If system time and date are set manually, the request shall include UTCDateTime.
    A TimeZone token which is not formed according to the rules of IEEE 1003.1 section 8.3 is considered as invalid timezone.
    The DayLightSavings flag should be set to true to activate any DST settings of the TimeZone string. Clear the DayLightSavings flag if the DST portion of the TimeZone settings should be ignored.
    The configuration requires a %Onvif.Devices.SystemDateAndTime{} config and a bolean set_time? to manually change the time. It will be ignored if using NTP.

    Ref: https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl#op.SetSystemDateAndTime
  """
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Devices.Schemas.SystemDateAndTime

  def soap_action, do: "http://www.onvif.org/ver10/device/wsdl/SetSystemDateAndTime"

  @spec request(Device.t(), list) :: {:ok, any} | {:error, map()}
  def request(device, args) do
    Onvif.Devices.request(device, args, __MODULE__)
  end

  def request_body(config: %SystemDateAndTime{} = system_date_time) do
    request_body(config: system_date_time, set_time?: false)
  end

  def request_body(config: %SystemDateAndTime{} = system_date_time, set_time?: set_time?) do
    element(:"s:Body", [
      element(:"tds:SetSystemDateAndTime", [
        element(
          :"tds:DateTimeType",
          Keyword.fetch!(
            Ecto.Enum.mappings(system_date_time.__struct__, :date_time_type),
            system_date_time.date_time_type
          )
        ),
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
