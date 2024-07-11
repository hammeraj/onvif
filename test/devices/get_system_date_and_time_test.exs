defmodule Onvif.Devices.GetSystemDateAndTimeTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "GetSystemDateAndTime/1" do
    test "should parse with correct values" do
      xml_response = File.read!("test/devices/fixtures/get_system_date_and_time.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      Mimic.expect(DateTime, :utc_now, fn ->
        ~U[2024-07-09 20:00:00.227234Z]
      end)

      {:ok, service_capabilities} = Onvif.Devices.GetSystemDateAndTime.request(device)

      assert service_capabilities == %Onvif.Devices.SystemDateAndTime{
               current_diff: -654,
               date_time_type: :manual,
               datetime: ~U[2024-07-09 19:49:06Z],
               daylight_savings: true,
               local_date_time: %Onvif.Devices.SystemDateAndTime.LocalDateTime{
                 date: %Onvif.Devices.SystemDateAndTime.LocalDateTime.Date{
                   day: 9,
                   month: 7,
                   year: 2024
                 },
                 time: %Onvif.Devices.SystemDateAndTime.LocalDateTime.Time{
                   hour: 16,
                   minute: 49,
                   second: 6
                 }
               },
               time_zone: %Onvif.Devices.SystemDateAndTime.TimeZone{
                 tz: "BRT3"
               },
               utc_date_time: %Onvif.Devices.SystemDateAndTime.UTCDateTime{
                 date: %Onvif.Devices.SystemDateAndTime.UTCDateTime.Date{
                   day: 9,
                   month: 7,
                   year: 2024
                 },
                 time: %Onvif.Devices.SystemDateAndTime.UTCDateTime.Time{
                   hour: 19,
                   minute: 49,
                   second: 6
                 }
               }
             }
    end
  end
end
