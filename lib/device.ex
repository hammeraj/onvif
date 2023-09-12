defmodule Onvif.Device do
  @enforce_keys [:username, :password, :address]

  @type t :: %__MODULE__{}

  defstruct @enforce_keys ++
              [
                :auth_type,
                :scopes,
                :manufacturer,
                :model,
                :firmware_version,
                :serial_number,
                :hardware_id,
                :ntp,
                :media_service_path,
                time_diff_from_system_secs: 0,
                port: 80,
                supports_media2?: false,
                device_service_path: "/onvif/device_service"
              ]
end
