defmodule Onvif.Devices.GetSystemDateAndTimeTest do
  use ExUnit.Case, async: true

  alias Onvif.Devices.Schemas.SystemDateAndTime

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

      assert service_capabilities == %SystemDateAndTime{
               current_diff: -654,
               date_time_type: :manual,
               datetime: ~U[2024-07-09 19:49:06Z],
               daylight_savings: true,
               local_date_time: %SystemDateAndTime.LocalDateTime{
                 date: %SystemDateAndTime.LocalDateTime.Date{
                   day: 9,
                   month: 7,
                   year: 2024
                 },
                 time: %SystemDateAndTime.LocalDateTime.Time{
                   hour: 16,
                   minute: 49,
                   second: 6
                 }
               },
               time_zone: %SystemDateAndTime.TimeZone{
                 tz: "BRT3"
               },
               utc_date_time: %SystemDateAndTime.UTCDateTime{
                 date: %SystemDateAndTime.UTCDateTime.Date{
                   day: 9,
                   month: 7,
                   year: 2024
                 },
                 time: %SystemDateAndTime.UTCDateTime.Time{
                   hour: 19,
                   minute: 49,
                   second: 6
                 }
               }
             }
    end

    test "should return error when response is invalid" do
      xml_response = File.read!("test/devices/fixtures/invalid_system_date_and_time_response.xml")
      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 400, body: xml_response}}
      end)

      {:error, %{status: status, reason: reason, response: response}} =
        Onvif.Devices.GetSystemDateAndTime.request(device)

      assert status == 400
      assert reason == "Received 400 from Elixir.Onvif.Devices.GetSystemDateAndTime"
      assert response == xml_response
    end
  end
end
