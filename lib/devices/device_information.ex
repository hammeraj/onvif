defmodule Onvif.Devices.DeviceInformation do
  @derive Jason.Encoder
  defstruct [:manufacturer, :model, :firmware_version, :serial_number, :hardware_id]
end
